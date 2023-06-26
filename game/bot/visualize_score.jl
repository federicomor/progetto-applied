using DataFrames
using CSV
using UnicodePlots
# using Plots
using Dates

data = DataFrame(CSV.File("df.csv",stringtype=String))
# data = data[isequal.(data.zdone,1),:]
# select the done=1 players
sort!(data,:score,rev=true)
# ora il dataset è ordinato


############# Scoreboard 1 #############
# println("Writing scoreboard 1...")

# f = open("scoreboard.md", "w")

# write(f,"# 🚩 Final Scoreboard \n\n")
# write(f,"Position | Player Name | Score \n")
# write(f,"--- | --- | ---\n")

# for i in 1:size(data)[1]
# 	player_name = data[i,:player_name]
# 	player_id = data[i,:player_id]
# 	score = data[i,:score]

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
f = open("scoreboard_plot.md", "w")

write(f,"# 🚩 Live Scoreboard\n")
write(f,"Game ends at 19:00! ")
t = now()
write(f,"Last update at time $(string(t)[12:16])\n")
write(f,"```R\n")

# t_end = Dates.Time(19,00,00)
# t_now = Dates.Time(now())

P = barplot(string.(data[:,:player_name]," ",1:size(data)[1] ),
	round.(data[:,:score],digits=2),
	# width=:auto,
	width = 20, # così stretta che forse dal telefono si vede meglio
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