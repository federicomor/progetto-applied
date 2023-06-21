using DataFrames
using CSV

data = DataFrame(CSV.File("df.csv",stringtype=String))
sort!(data,:score,rev=true)
# ora il dataset è ordinato

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