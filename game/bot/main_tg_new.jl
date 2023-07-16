println("Loading libraries.")
using Telegram, Telegram.API
using ConfigEnv
using DataFrames
# https://dataframes.juliadata.org/stable/man/basics/
using Dates
using CSV
# DataFrame(CSV.File("file.csv"))
# CSV.write("file.csv", df)


############# Debug stuff #############
dotenv()
println(getMe())

BOT_API = "6203755027:AAFvDKYwPUSFJeOHs97fjjpuzk2vF9kBaws"
tg = TelegramClient(BOT_API)
@show ARGS


############# Dataframe handling #############
cols_dict = Dict(
    "player_id"=>Int64(0),"player_name"=>"Pippo",
    "state"=>"ITA",
    "tec"=>Float64(0),"tch"=>Float64(0),"sch"=>Float64(0),
    "stu"=>Float64(0),"fam"=>Float64(0),
    "score"=>Float64(0),
    "zdone"=>Int64(0) ) # z to let it be at the end of the dataframe
df = DataFrame(cols_dict)

@show df
empty!(df)
@show df
describe(df)

# maybe this should always be done
ALWAYS_RECOVER = true
if ("rec" in ARGS || ALWAYS_RECOVER)
    println("Recovering the previous dataframe.")
    df = DataFrame(CSV.File("df.csv")) #,stringtype=String))
    @show df
end

# println("We are online.")

println("Including files.")
############# Include dataframe functions #############
include("dataframe_functions.jl")
println("Created linear mixed model.")


############# Global const variables #############
include("const_variables.jl")


############# Include game functions #############
include("game_functions.jl")


println("Ready to play.")
############# Real program #############
function handle_command(msg)
    chat_id = ""
    msg_text = ""
    name = ""
    username = ""

    e = Any
    # safety first! 
    try
        if haskey(msg,"message")
            chat_id = msg.message.chat.id
            msg_text = msg.message.text
            name = msg.message.from.first_name    
            username = msg.message.from.username    
        else
            chat_id = msg.edited_message.chat.id
            msg_text = msg.edited_message.text
            name = msg.edited_message.from.first_name    
            username = msg.edited_message.from.username 
        end
    catch e
        @show e
        if isa(e,ErrorException)
            sendMessage(tg,
                text="$(e.msg)",
                chat_id = chat_id)
            return
        end
    end



    if chat_id=="" || msg_text==""
        return
    end

    who = "$chat_id"
    if name != ""
        who=name
    end
    if username != ""
        who=username
    end

    msg_text = replace("$msg_text", "\\" => "/")
    println("$chat_id = $who -> $msg_text")

    player_id = chat_id
    if !is_player_registered(player_id)
        register_player(player_id, who)
    end


    if msg_text == "/start"
        # @show chat_id
        sendMessage(tg,
            text="Hello $(who)!\nTechnically, you for me are $chat_id",
            # text="Hello $(who)!\nTechnically, you for me are $(who==chat_id ? "still $chat_id" : "$chat_id")",
            chat_id=chat_id)
        sendMessage(tg,
            text="Talk with us at our stand to undertand the game procedure, or read the instructions through the command /help.",
            chat_id=chat_id)
        # print_help(chat_id)


    elseif msg_text == "/help"
        print_help(chat_id)


    elseif msg_text == "/done"
        if get_player_data(player_id,:zdone) == 1
            sendMessage(tg,
                text="Your first game was the one who determined your position in the scoreboard (for that, see /results). But with the new parameters you provided, your score would have been...\n$(round(compute_score(player_id),digits=4))\nagainst your recorded one of\n$(round(get_player_data(player_id,:score),digits=4))",
                chat_id=chat_id)
        else
            sendMessage(tg,
                text="*Danger zone!*\nYou are about to confirm your game parameters, and so you won't be able to change them after that. If your are sure, type \"/done yes\" to actually confirm them.",
                chat_id=chat_id,
                parse_mode="Markdown")
        end


    elseif msg_text == "/done yes"
        if get_player_data(player_id,:state) == "missing"
            sendMessage(tg,
                text="Please choose the state before confirming your parameters. See the options with /state.",
                chat_id=chat_id)
        else # qui il player ha scelto lo stato
            if get_player_data(player_id,:zdone) == 1
                sendMessage(tg,
                    # Your first game was the one who determined your position in the scoreboard (for that, see /results). But with
                    text="With the new parameters you provided, your score would have been...\n$(round(compute_score(player_id),digits=4))\nagainst your recorded one of\n$(round(get_player_data(player_id,:score),digits=4))",
                    chat_id=chat_id)
            else
                set_player_data(player_id, :zdone, 1)
                sendMessage(tg,
                    text="Game parameters confirmed! We are now computing your score for the global scoreboard (see your ranking through /results).\n*Alert*\nThis score of yout first play is the one which will appear in the scoreboard. However you can still experiment with the bot, trying different parameters, see how your score would have changed, and so on.",
                    chat_id=chat_id)
                set_player_data(player_id,:score,compute_score(player_id))
                include("visualize_score.jl")
            end
        end



    elseif msg_text == "/summary"
        sendMessage(tg,
            text=summary_player(player_id),
            chat_id = chat_id)
            # parse_mode="Markdown")


    elseif msg_text == "/results"
        sendMessage(tg,
            text="Remember, your fist play is the one which determined your position. Come here to see it!\nhttps://github.com/federicomor/project_game_scoreboard/blob/main/scoreboard.md",
            chat_id = chat_id)


    elseif msg_text == "/state"
        to_send = """
            Choose the state you want to play with. These are the possibilities:

            *HRV* = Croatia
            *CZE* = Czech Republic
            *DNK* = Denmark
            *EST* = Estonia
            *FIN* = Finland
            *FRA* = France
            *GRC* = Greece
            *HUN* = Hungary
            *LTU* = Lithuania
            *POL* = Poland
            *SVK* = Slovakia
            *SVN* = Slovenia
            *ESP* = Spain
            
            How to set your parameters: send a message in the form "keyword value" (where keyword is now _play_). So for example _play FRA_ will select France as your country to play with."""
            #*LUX* = Luxembourg
        sendMessage(tg,
            text=to_send,
            chat_id = chat_id,
            parse_mode="Markdown")
        sendMessage(tg,
            text="There is no \"right\" choice here, choose the state based on your feeling, your simpathy for one of them, or your believe that a certain state will have a positive effect on the well being of the children.",
            chat_id = chat_id)


    elseif msg_text == "/budget"
        to_send = """
            Choose how you want to manage your budget. How much do you want to invest on the following categories?

            *tec* = technology
            Make more available technology for children, increasing their contact with computers, at home and school, for studying, gaming, chatting, etc.
            *tch* = teacher
            Invest in increasing teachers' skills, in hiring more qualified people, etc.
            *sch* = school
            Manage schools to have enough materials and personal, balance student/professors ratio, class sizes, introduce external activities, etc.
            *stu* = culture
            Make students spend more time studying, and in general enjoying cultural activities, like reading, playing small challenges, also toghether with their classmates, etc.
            *fam* = family
            Increase the educational resources that family can give to their children, and try to also support them financially, with bonuses, etc.

            How to set your parameters: send a message in the form "keyword value" (where keywords are now _tec, tch, sch, stu, fam_). So for example _tec 30_ will select to invest 30% of your budget in the category technology."""
        sendMessage(tg,
            text=to_send,
            chat_id = chat_id,
            parse_mode="Markdown")
        sendMessage(tg,
            text="Give a value between 0 and 100 for each category, the values should add up to 100 but don't worry for possile mistakes, we will fix them (if any) normalizing everything at the end.",
            chat_id = chat_id,
            parse_mode="Markdown")


    # just a random test with numbers
    # elseif match(r"^[0-9 \.]+$", msg_text) !== nothing
    #     x = []
    #     e=Any
    #     try 
    #         x = parse.(Float64, split(msg_text, " "))
    #     catch e
    #     end
    #     if isa(e,ArgumentError)
    #         sendMessage(tg,
    #             text = "Error: $(e.msg)",
    #             chat_id=chat_id)
    #     else
    #         sendMessage(tg,
    #             text = "Your number squared is $(x.^2)",
    #             chat_id=chat_id)
    #     end
    

    ############# Messages controlled by me #############
    # using my chat_id as reference

    elseif lowercase(msg_text)=="/show df" && chat_id==641681765
        @show df

    elseif lowercase(msg_text)=="/update scoreboard" && chat_id==641681765
        include("visualize_score.jl")

    ############# DANGER ZONE #############
    elseif occursin("/bcast",lowercase(msg_text)) && chat_id==641681765
        to_send = replace(msg_text,"/bcast" => "")
        if to_send != ""
            bcast(to_send)
        end

    elseif occursin("/exec",lowercase(msg_text)) && chat_id==641681765
        try
            commad = replace(msg_text,"/exec" => "")
            eval(Meta.parse(commad))
        catch e
            @show e
        end

    # elseif lowercase(msg_text)=="/done for all" && chat_id==641681765
    #     try
    #         bcast("Time's up, game ended! The final results are now available here\nhttps://github.com/federicomor/project_game_scoreboard/blob/main/scoreboard.md")
    #     catch e
    #         @show e
    #     end
    #     for idd in df.player_id
    #         try
    #             if get_player_data(idd,:zdone)==0
    #                 if get_player_data(idd,:state) == "nothing"
    #                     set_player_data(idd,:state,rand(STATES)) # default random one
    #                 end
    #                 set_player_data(idd, :zdone, 1)
    #                 # normalize_player_data(idd)
    #                 compute_score(idd)
    #             end
    #         catch e
    #             @show e
    #         end
    #     end    

    ############# end #############

    ## we are in the "keyword value" case
    ## moved to last to not interfere with other commands long 2 strings
    elseif length(split(msg_text," "))==2
        if is_valid_keyword(split(msg_text," ")[1])
            sendMessage(tg,
                text = process_keyword_value(msg_text, player_id),
                chat_id=chat_id)
        else
            sendMessage(tg,
                text = "I didn't manage to parse your input correctly.\nSo I will cowardly ignore your message.",
                chat_id=chat_id)
        end


    else
        sendMessage(tg,
            text = "I didn't manage to parse your input correctly.\nSo I will cowardly ignore your message.",
            chat_id=chat_id)

    end
end


function main()
    run_bot() do msg
        # @show msg
        # @show typeof(msg)
            handle_command(msg)
        # @show df
        CSV.write("df.csv", df)

        ## Backup
        # t0 = string(now())
        # csv_backup = "df_backup_h$(t0[12:13]).csv"
        # csv_backup = "df_backup_h$(t0[12:13])m$(t0[15:16]).csv"
        # CSV.write("$csv_backup", df)
    end
end

# Avvia il bot
main()