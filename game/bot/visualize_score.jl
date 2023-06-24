using DataFrames
using CSV
using UnicodePlots
# using Plots

data = DataFrame(CSV.File("df.csv",stringtype=String))
sort!(data,:score,rev=true)
# ora il dataset è ordinato

############# Scoreboard 1 #############
println("Writing scoreboard 1...")

f = open("scoreboard.md", "w")

write(f,"# 🚩 Final Scoreboard \n\n")
write(f,"Position | Player Name | Score \n")
write(f,"--- | --- | ---\n")

for i in 1:size(data)[1]
	player_name = data[i,:player_name]
	player_id = data[i,:player_id]
	score = data[i,:score]

	i==1 && write(f,"🥇 | $(player_name) | $score\n")
	i==2 && write(f,"🥈 | $(player_name) | $score\n")
	i==3 && write(f,"🥉 | $(player_name) | $score\n")

	if i>=4
		 write(f,"$i | $(player_name) | $score\n")
	end
end
close(f)
println("done.")


############# Scoreboard 2 #############
println("Writing scoreboard 2...")
f = open("scoreboard_plot.md", "w")

write(f,"# 🚩 Final Scoreboard\n\n")
write(f,"```\n")

P = barplot(data[:,:player_name],data[:,:score])
savefig(p,"plot.md")
for line in eachline("plot.md")
	write(f,"$line\n")
end

write(f,"```\n")
close(f)
println("done.")