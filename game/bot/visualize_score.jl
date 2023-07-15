############# paramteri importanti #############
CALLING_FROM_TERMINAL = 0
FILTER_DONE = 0

############# parametri meno importanti #############
NEED_TO_COMPUTE_SCORE = 1
WRITE_NEW_DF_scored = 0

if CALLING_FROM_TERMINAL==1
	println("Loading libaries.")
end

using DataFrames
using CSV
using UnicodePlots
# using Plots
using Dates
using Random

score_data=Any

if CALLING_FROM_TERMINAL==1
	df = DataFrame(CSV.File("df.csv")) #,stringtype=String))
	include("dataframe_functions.jl")
	include("const_variables.jl")
	score_data=df
else
	score_data=df
end

if NEED_TO_COMPUTE_SCORE==1
	println("Computing the score.")
	for idd in df.player_id
		compute_score(idd)
	end
score_data=df
end

if FILTER_DONE==1 && sum(isequal.(df.zdone,1))>=1
	score_data = score_data[isequal.(df.zdone,1),:]
end
if FILTER_DONE==1
	score_data = df[isequal.(df.zdone,1),:]
else
	score_data=df
end


if WRITE_NEW_DF_scored==1
	println("Writing the new df filled with scores.")
	CSV.write("df.csv", score_data)
end

# println("Sorting the data.")
sort!(score_data,:score,rev=true)
# ora il dataset è ordinato
println(score_data)

correzione_punteggio = 0
if minimum(score_data.score)<0
	shift = abs(minimum(score_data.score))
	pietà = 10+rand((MersenneTwister(34))) # punteggio minimo
	correzione_punteggio = shift*100 + pietà
	# correzione_punteggio = (shift+pietà)*100
else
	correzione_punteggio = 0
end


############# Scoreboard 1 #############
# println("Writing scoreboard 1...")

# f = open("scoreboard.md", "w")

# write(f,"# 🚩 Final Scoreboard \n\n")
# write(f,"Position | Player Name | Score \n")
# write(f,"--- | --- | ---\n")

# for i in 1:size(df)[1]
# 	player_name = df[i,:player_name]
# 	player_id = df[i,:player_id]
# 	score = df[i,:score]

# 	i==1 && write(f,"🥇 | $(player_name) | $score\n")
# 	i==2 && write(f,"🥈 | $(player_name) | $score\n")
# 	i==3 && write(f,"🥉 | $(player_name) | $score\n")

# 	if i>=4
# 		 write(f,"$i | $(player_name) | $score\n")
# 	end
# end
# close(f)
# println("done.")


############# Scoreboard 2 #############
println("Writing scoreboard 2...")
f = open("project_game_scoreboard/scoreboard.md", "w")

write(f,"# 🚩 Live Scoreboard\n")
write(f,"Game ends at 19:00!   \n")
t = now()
write(f,"Last update at time $(string(t)[12:16])\n")
write(f,"```R\n")

# t_end = Dates.Time(19,00,00)
# t_now = Dates.Time(now())



# P = barplot(string.(data[:,:player_name]," [",string.(data[:,:state]),"] ",lpad.(1:size(data)[1],3)), # con spazio uguale tra stringhe e cifre

P = barplot(string.(score_data[:,:player_name],
	" [",string.(score_data[:,:state]),"] ", # mostra anche lo stato scelto
	# " ", # così no invece, solo player_name
	1:size(score_data)[1] ),
	round.(score_data[:,:score] .* 100 .+ correzione_punteggio,digits=4),
	# width=:auto,
	width = 30, # così stretta che forse dal telefono si vede meglio
	# nevermind si può scorrere
	# title="Game ends at 19:00!",
	# symbols=['#'],
	# border=:corners  # :corners, :solid, :bold, :dashed, :dotted, :ascii, :none
	)

savefig(P,"plot.txt")

println(P)

for line in eachline("plot.txt")
	write(f,"$(replace("$line\n", r".*[┌|└].*" => ""))")
end

write(f,"```\n")
Base.close(f)
println("done.")

try
	println("Updating scoreboard on github...")
	include("project_game_scoreboard/update_all.jl")
	println("done.")
catch e
	@show e
end