using DataFrames
using CSV
using UnicodePlots
# using Plots
using Dates

############# parameters #############
NEED_TO_COMPUTE_SCORE = 1
FILTER_DONE = 0
WRITE_NEW_DF = 0
##########################

df = DataFrame(CSV.File("df.csv",stringtype=String))

include("dataframe_functions.jl")
include("const_variables.jl")

if NEED_TO_COMPUTE_SCORE==1
	for idd in df.player_id
		compute_score(idd)
	end
end

if WRITE_NEW_DF==1
	CSV.write("df.csv", df)
end


if FILTER_DONE==1
	df = df[isequal.(df.zdone,1),:]
	# select the done=1 players
end

sort!(df,:score,rev=true)
# ora il dataset è ordinato

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

P = barplot(string.(df[:,:player_name]," ",1:size(df)[1] ),
	round.(df[:,:score],digits=2),
	# width=:auto,
	width = 30, # così stretta che forse dal telefono si vede meglio
	# nevermind si può scorrere
	# title="Game ends at 19:00!",
	# symbols=['#'],
	# border=:corners  # :corners, :solid, :bold, :dashed, :dotted, :ascii, :none
	)

savefig(P,"plot.txt")

for line in eachline("plot.txt")
	write(f,"$(replace("$line\n", r".*[┌|└].*" => ""))")
end

write(f,"```\n")
close(f)
println("done.")
