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
    "tec"=>Float64(0),"psi"=>Float64(0),"clt"=>Float64(0),
    "fam"=>Float64(0),"tch"=>Float64(0),"sch"=>Float64(0),
    "score"=>Float64(0),
    "zdone"=>Int64(0) ) # z to let it be at the end of the dataframe
df = DataFrame(cols_dict)

@show df
empty!(df)
@show df
describe(df)

# maybe this should always be done
if ("rec" in ARGS || 1==1)
    println("Recovering the previous dataframe.")
    df = DataFrame(CSV.File("df.csv",stringtype=String))
    @show df
end

# println("We are online.")

############# Include dataframe functions #############
include("dataframe_functions.jl")


############# Global const variables #############
include("const_variables.jl")


############# Include game functions #############
include("game_functions.jl")


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
            text="Talk with us at our stand to undertand the game procedure. Or read the instructions through the command /help.",
            chat_id=chat_id)
        # print_help(chat_id)


    elseif msg_text == "/help"
        print_help(chat_id)


    elseif msg_text == "/done"
        if get_player_data(player_id,:zdone) == 1
                sendMessage(tg,
                    text="Game parameters already confirmed! Type /results to see your ranking in the scoreboard!",
                    chat_id=chat_id)
        else
            sendMessage(tg,
                    text="*Danger zone!* You are about to confirm your game parameters, and so you won't be able to change them after that.\nIf your are sure, type \"/done yes\" to actually confirm them.",
                    chat_id=chat_id,
                    parse_mode="Markdown")
        end


    elseif msg_text == "/done yes"
        if get_player_data(player_id,:state) == "missing"
            sendMessage(tg,
                text="Please choose the state before confirming your parameters.",
                chat_id=chat_id)
        else
            if get_player_data(player_id,:zdone) == 1
                sendMessage(tg,
                    text="Game parameters already confirmed! Type /results to see your ranking in the scoreboard!",
                    chat_id=chat_id)
            else
                sendMessage(tg,
                    text="Game parameters confirmed! Now you can't change them anymore.\nWe are now normalizing your parameters (so that they sum up to 100), and then computing your score. Type /results to see your ranking in the scoreboard!",
                    chat_id=chat_id)
            
                set_player_data(player_id, :zdone, 1)
                # normalize_player_data(player_id) # normalizza già nella compute_score
                compute_score(player_id)
                include("visualize_score.jl")
            end
        end



    elseif msg_text == "/summary"
        sendMessage(tg,
            text=summary_player(player_id),
            chat_id = chat_id)
            # parse_mode="Markdown")


    elseif msg_text == "/results"
        if get_player_data(player_id,:zdone)==0
            sendMessage(tg,
                text="You firstly need to confirm your game parameters with /done to see your final score.",
                chat_id = chat_id)
        else
            sendMessage(tg,
                text="Come here to see your position!\nhttps://github.com/federicomor/project_game_scoreboard/blob/main/scoreboard.md",
                chat_id = chat_id)
        end


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
            *LUX* = Luxembourg
            *POL* = Poland
            *SVK* = Slovakia
            *SVN* = Slovenia
            *ESP* = Spain"""
        sendMessage(tg,
            text=to_send,
            chat_id = chat_id,
            parse_mode="Markdown")
        sendMessage(tg,
            text="There is no \"right\" choice here, choose the state based on your feeling, your simpathy for one of them, or your believe that a certain state will have a positive effect on the well being of the children.",
            chat_id = chat_id)


    elseif msg_text == "/budget"
        to_send = """
            Choose how you want to manage your budget. How much do you want to invest on the following categories? It is also indicated what will it mean to invest on a certain category.
            *tec* = technology
            More expertise and knowledge in the informatic for children.
            *psi* = psychology
            More awareness in the psychological context in which the children live.
            *clt* = culture
            An improvement in the cultural ambient quality where the children live.
            *fam* = family
            More awareness in the children needs from the parents.
            *tch* = teacher
            More awareness in the children needs from the teachers.
            *sch* = school
            A general improvement in the school quality."""
        sendMessage(tg,
            text=to_send,
            chat_id = chat_id,
            parse_mode="Markdown")
        sendMessage(tg,
            text="Give a value between 0 and 100 for each category, the values should add up to 100 but don't worry for possile mistakes, we will fix them (if any) normalizing everything to 100.",
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

    # elseif lowercase(msg_text)=="/ME_send_results" && chat_id==641681765
    #     sendMessage(tg,
    #         text = "Hey player, the final results are now available! Here you can find them\nhttps://github.com/federicomor/project_game_scoreboard/blob/main/scoreboard.md",
    #         chat_id=chat_id)


    ############# DANGER ZONE #############
    # elseif occursin("/bcast",lowercase(msg_text)) && chat_id==641681765
    #     to_send = replace(msg_text,"/bcast" => "")
    #     if to_send != ""
    #         bcast(msg_text)
    #     end


    elseif lowercase(msg_text)=="/done for all" && chat_id==641681765
        try
            bcast("Time's up, game ended! The final results are now available here\nhttps://github.com/federicomor/project_game_scoreboard/blob/main/scoreboard.md")
        catch e
            @show e
        end
        for idd in df.player_id
            try
                if get_player_data(idd,:zdone)==0
                    if get_player_data(idd,:state) == "nothing"
                        set_player_data(idd,:state,rand(STATES)) # default random one
                    end
                    set_player_data(idd, :zdone, 1)
                    # normalize_player_data(idd)
                    compute_score(idd)
                end
            catch e
                @show e
            end
        end    

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
        # csv_name = "df_backup_$(string(now())[1:13]).csv"
        # CSV.write("$csv_name", df)
    end
end

# Avvia il bot
main()