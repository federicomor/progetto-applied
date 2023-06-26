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

# include("functions.jl")
function is_player_registered(player_id)
    return player_id in df.player_id
end

function register_player(player_id, player_name="missing")
    push!(df, Dict(:player_id => player_id, :player_name => player_name,
                :state => "missing",
                :tec=>Float64(0),:psi=>Float64(0),:clt=>Float64(0),
                :fam=>Float64(0),:tch=>Float64(0),:sch=>Float64(0),
                :score => Float64(0), :zdone => Int64(0)))
end

# set_player_data(1234,:player_name,"Gio")
function set_player_data(player_id, field::Symbol, value)
    if !is_player_registered(player_id)
        register_player(player_id)
    end
        df[findfirst(isequal.(df.player_id,player_id)),field] = value
end

function get_player_data(player_id, field::Symbol)
    try
        return df[findfirst(isequal.(df.player_id,player_id)),field]
    catch e
    end
    return NaN
end
# get_player_data(id,:state)
function get_player_data(player_id, field::String)
    try
        return df[findfirst(isequal.(df.player_id,player_id)),Symbol(field)]
    catch e
    end
    return NaN
end
# get_player_data(id,"state")


function normalize_player_data(player_id)
    tot = 0
    for categ in CATEGORIES
        tot += df[findfirst(isequal.(df.player_id,player_id)),Symbol(categ)]
    end
    if tot != 0
        for categ in CATEGORIES
            df[findfirst(isequal.(df.player_id,player_id)),Symbol(categ)] /= (tot/100)
        end
    end
end


function compute_score(player_id)
    include("get_sol.jl") # this let the dictionary sol available here
    # We should not put that get_sol.jl file on github, 
    # and just keep it locally, otherwise users can read it and cheat

    score = 0
    position = findfirst(isequal.(df.player_id,player_id))
    state = df[position, :state]
    for cat in CATEGORIES
        score += 1 - abs((df[position,"$cat"]-sol["$state"]["$cat"])/
                         (df[position,"$cat"]+sol["$state"]["$cat"]))
        # circa la canberra distance?
        # max punteggio 6, min punteggio dipende
    end
    score = score/6*100
    set_player_data(player_id,:score,score)
end


function summary_player(player_id)
    df_player = df[findfirst(isequal.(df.player_id,player_id)),:]
        # player_id = $(df_player[3])
    to_send = """
        player_name = $(df_player[4] =="missing" ? "NA" : df_player[4])
        state = $(df_player[8]=="missing" ? "NA" : df_player[8])
        tec = $(round(df_player[10],digits=3))
        psi = $(round(df_player[5],digits=3))
        clt = $(round(df_player[1],digits=3))
        fam = $(round(df_player[2],digits=3))
        tch = $(round(df_player[9],digits=3))
        sch = $(round(df_player[6],digits=3))
        done? = $(df_player[11]==1 ? "yes" : "not yet")"""
        # Fill all the NAs to setup your game!
    return to_send
end


############# Global const variables #############
STATES = [ "HRV" "CZE" "DNK" "EST" "FIN" "FRA" "GRC" "HUN" "LTU" "LUX" "POL" "SVK" "SVN" "ESP" ]

FULL_STATES = Dict(
    "HRV"=>"Croatia",
    "CZE"=>"Czech Republic",
    "DNK"=>"Denmark",
    "EST"=>"Estonia",
    "FIN"=>"Finland",
    "FRA"=>"France",
    "GRC"=>"Greece",
    "HUN"=>"Hungary",
    "LTU"=>"Lithuania",
    "LUX"=>"Luxembourg",
    "POL"=>"Poland",
    "SVK"=>"Slovakia",
    "SVN"=>"Slovenia",
    "ESP"=>"Spain" )

CATEGORIES = ["tec" "psi" "clt" "fam" "tch" "sch"]
KEYWORDS = ["callme" "play" "tec" "psi" "clt" "fam" "tch" "sch"]


############# Real program #############
function print_help(chat_id)
    str1 = """
    *Idea of the game*
    The PISA dataset that we had contained data gathered from questionnaires compiled by children in mid schools. We grouped all those data into different categories (technology, psychology, culture, familiy, teachers, school) and with our statistical analysis we were able to sort out not only in which states there were the better schools, in terms of general well-being of the students, but also which impact those categories have, singularly, in the final position of the state in the ranking, together with the effect of the state itself.

    So we setup a game, a bit similar to Risiko or Monopoli: you have to choose your character, the state to play with, and how to spend your budget on the various categories, like if you were the "Minister of Education" in that state. We will then rank your choice and build up a global scoreboard with also everyone else who will play the game."""

    str2 = """
    *Instructions to play the game*
    (1) Type /start to get the welcome message.
    (2) Type /help to read again the instructions.
    (2) Type /state to choose the state to play with.
    (3) Type /budget to implement your strategy.
    (4) Type /summary to see your game parameters.
    (5) Type /done to confirm your parameters choice.
    (6) Type /results to see your position in the ranking!"""

    str3 = """
    *Command execution*
    Each interactive command expects that you send a message in the form "*keyword value*", a syntax which let us set a certain parameter game to the value you want to assign. 
    For example "play ESP" selects ESP as the state to play with, "tec 60" selects to invest 60% of your budget on category technology, "callme Jhonny" selects your username to be Jhonny, etc.

    Keywords are: _callme, play, tec, psi, clt, fam, tch, sch_. Values should be: a string (for the state and callme) or a number (for the budget). All is case-insensitive, so callme or Callme or CallMe won't get the bot crash, for example.
    """
    # useremo la funzione lowercase(input) ovunque
    sendMessage(tg,
            text=str1,
            chat_id = chat_id,
            parse_mode="Markdown")
        sendMessage(tg,
            text=str2,
            chat_id = chat_id,
            parse_mode="Markdown")
        sendMessage(tg,
            text=str3,
            chat_id = chat_id,
            parse_mode="Markdown")
    
end


############# Program functions #############

# function filter_value_to_Number(text, T::DataType)
#     # filter_value("psi 13",Int64) -> 13
#     # filter_value("psi 13",Float64) -> 13.0
#     target = split(text," ")[1]
#     value = split(text," ")[2]
#     return (target,parse(T, value))
# end

# function filter_value_to_String(text)
#     target = split(text," ")[1]
#     value = split(text," ")[2]
#     return (target,value)
# end

# function filter_value(text)
#     target = split(text," ")[1]
#     value = split(text," ")[2]
#     return (target,value)
# end

function is_valid_keyword(text)
    if (lowercase(text) in KEYWORDS) || (lowercase(text[2:end]) in KEYWORDS)
        return true
    end
    return false
end

function which_keyword(text)
    key = split(text," ")[1]
    if key[1]=="/"
        key = key[2:end]
    end
    return KEYWORDS[findfirst(isequal.(KEYWORDS,lowercase(key)))[2]]
end

function process_keyword_value(text, player_id)
    key = which_keyword(text)
    val = split(text," ")[2]
    done = df[findfirst(isequal.(df.player_id,player_id)),:zdone]

    if key == "callme" # && done==0
        # maybe one can still change his/her player_name even after /done
        if in(val,df[:,:player_name])
            return "Error: name already taken."
        else
            set_player_data(player_id, :player_name, val)
            return "Game parameters updated."
        end
    elseif key == "play" && done==0
        if uppercase(val) in STATES || val in STATES
            set_player_data(player_id, :state, uppercase(val))
            return "Game parameters updated."
        else
            return "Error: give a correct state acronym."
        end
    elseif key != "play" && key != "callme" && done==0
        val_num = 0
        try 
            val_num = parse(Float64,val)
        catch e
            # return "Error: $e"
            return "Error: $(e.msg)"
        end
        if 0<=val_num<=100
            set_player_data(player_id, Symbol(key), val_num)
            # normalize_player_data(player_id)
            return "Game parameters updated."
        else
            return "Error: give a value in [0,100]."
        end
    else
        return "You can't change anymore your game parameters."
    end

    return "Something went wrong here."
end


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
    end

    @show e
    if isa(e,ErrorException)
        sendMessage(tg,
            text="$(e.msg)",
            chat_id = chat_id)
        return
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

    player_id = chat_id
    if !is_player_registered(player_id)
        register_player(player_id, who)
    end



    if msg_text == "/start"
        @show chat_id
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
        if get_player_data(player_id,:state) == "missing"
            sendMessage(tg,
                text="Please choose the state before confirming your parameters.",
                chat_id=chat_id)
        else
            sendMessage(tg,
                text="Game parameters confirmed! Now you can't change them anymore. We are now computing your score, so type /results to see your ranking in the scoreboard!",
                chat_id=chat_id)
        
            set_player_data(player_id, :zdone, 1)
            normalize_player_data(player_id)
            compute_score(player_id)
        end



    elseif msg_text == "/summary"
        sendMessage(tg,
            text=summary_player(player_id),
            chat_id = chat_id)
            # parse_mode="Markdown")


    elseif msg_text == "/results"
        sendMessage(tg,
            text="Come here and see your position!\nhttps://github.com/federicomor/progetto-applied/blob/main/game/bot/scoreboard_plot.md",
            chat_id = chat_id)
        # per farlo andare c'è da rendere pubblica la nostra repository

        # ff = open("scoreboard_plot.md","r")
        # s = read(ff, String)
        # sendMessage(tg,
        #     text="$s",
        #     chat_id = chat_id,
        #     parse_mode="Markdown")



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
            text="Give a value between 0 and 100 for each category, the values should add up to 100 but don't worry for possile mistakes, we will fix them (if any) normalizing everything to 1.",
            chat_id = chat_id,
            parse_mode="Markdown")


    # just a random test with numbers
    elseif match(r"^[0-9 \.]+$", msg_text) !== nothing
        x = []
        e=Any
        try 
            x = parse.(Float64, split(msg_text, " "))
        catch e
        end
        if isa(e,ArgumentError)
            sendMessage(tg,
                text = "Error: $(e.msg)",
                chat_id=chat_id)
        else
            sendMessage(tg,
                text = "Your number squared is $(x.^2)",
                chat_id=chat_id)
        end
        


    ## we are in the "keyword value" case
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


    ############# Messages controlled by me #############
    # using my chat_id as reference

    elseif lowercase(msg_text)=="/ME_send_results" && chat_id==641681765
        sendMessage(tg,
            text = "Hey player, the final results are now available! Here you can find them\nhttps://github.com/federicomor/progetto-applied/blob/main/game/bot/scoreboard.md",
            chat_id=chat_id)

    elseif occursin("/ME_bcast",lowercase(msg_text)) && chat_id==641681765
        to_send = replace(msg_text,"/bcast" => "")
        if to_send != ""
            sendMessage(tg,
                text = to_send,
                chat_id=chat_id)
        end

    ############# DANGER ZONE #############
    elseif occursin("/ME_done_for_all",lowercase(msg_text)) && chat_id==641681765
        sendMessage(tg,
            text = "Time's up, game ended!",
            chat_id=chat_id)
        for idd in df.player_id
            try
                if get_player_data(idd,:zdone)==0
                    if get_player_data(idd,:state) == "nothing"
                        set_player_data(idd,:state,rand(STATES)) # default random one
                    end
                    set_player_data(idd, :zdone, 1)
                    normalize_player_data(idd)
                    compute_score(idd)
                end
            catch e
                @show e
            end
        end    

    ############# end #############

    else
        sendMessage(tg,
            text = "I didn't manage to parse your input correctly.\nSo I will cowardly ignore your message.",
            chat_id=chat_id)

    end
end


function main()
    run_bot() do msg
        @show msg
        # @show typeof(msg)
            handle_command(msg)
        @show df
        CSV.write("df.csv", df)

        ## Backup
        # csv_name = "df_backup_$(string(now())[1:13]).csv"
        # CSV.write("$csv_name", df)
    end
end

# Avvia il bot
main()