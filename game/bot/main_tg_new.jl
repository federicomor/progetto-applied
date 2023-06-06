using Telegram, Telegram.API
using ConfigEnv
using DataFrames

# https://dataframes.juliadata.org/stable/man/basics/

############# Debug stuff #############
dotenv()
println(getMe())

BOT_API = "6203755027:AAFvDKYwPUSFJeOHs97fjjpuzk2vF9kBaws"
tg = TelegramClient(BOT_API)


############# Dataframe handling #############
cols_dict = Dict(
    "player_id"=>-1,"player_name"=>"Pippo",
    "state"=>"ITA",
    "tec"=>-1,"psi"=>-1,"clt"=>-1,"fam"=>-1,"tch"=>-1,"sch"=>-1,
    "score"=>0 )
df = DataFrame(cols_dict)
empty!(df)
describe(df)

function is_player_registered(player_id)
    return player_id in df.player_id
end

function register_player(player_id, player_name="missing")
    push!(df, Dict(:player_id => player_id, :player_name => player_name,
                :state => "missing",
                :tec=>0,:psi=>0,:clt=>0,:fam=>0,:tch=>0,:sch=>0,
                :score => 0))
end

# set_player_data(1234,:player_name,"Gio")
function set_player_data(player_id, field::Symbol, value)
    if !is_player_registered(player_id)
        register_player(player_id)
    end
        df[findfirst(isequal.(df.player_id,player_id)),field] = value
end
# for i in 1:10
    # set_player_data(i,:score,i^2)
# end
# sort(df,:score,rev=true)


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
function print_help()
    str = """
    *Idea of the game*
    The PISA dataset that we had contained data gathered from questionnaires compiled by children in mid schools. We grouped all those data into different categories (technology, psychology, culture, familiy, teachers, school) and with our statistical analysis we were able to sort out not only in which states there were the better schools, in terms of general well-being of the students, but also which impact those categories have, singularly, in the final position of the state in the ranking, together with the effect of the state itself.

    So we setup a game, a bit similar to Risiko or Monopoli: you have to choose your character, the state to play with, and how to spend your budget on the various categories, like if you were the "Minister of Education" in that state. We will then rank your choice and build up a global scoreboard with also everyone else who will play the game.

    *Instructions to play the game*
    (1) Type /start for the welcome message.
    (2) Type /state to choose the state to play with.
    (3) Type /budget to implement your strategy.
    (4) Talk with us at our poster section!
    (5) Type /results to see your position in the ranking!

    *Command execution*
    Each interactive command expects that you send a message in the form "*keyword value*", a syntax which let us set a certain parameter game to the value you want to assign. 
    For example "play ESP" selects ESP as the state to play with, "tec 60" selects to invest 60% of your budget on category technology, "callme Jhonny" selects your username to be Jhonny, etc.

    Keywords are: _callme, play, tec, psi, clt, fam, tch, sch_. Values should be: a string (for the state and callme) or a number (for the budget). All is case-insensitive, so callme or Callme or CallMe won't get the bot crash, for example.
    """
    # useremo la funzione lowercase(input) ovunque
    return str
end


## Idea: prendere tutti gli input dall'utente per definire il suo gioco. Forse ci sarà
## da filtrare anche in base a chat_id, perché non so se tipo questo codice viene eseguito
## più volte su diverse chat (come SIMD) o è solo un codice eseguito che gestisce tutti i
## messaggi (MISD). Per capirlo occorrà fare dei test.
## Se SIMD tutto easy, le variabili legate all'USER sono tutte indipendenti tra loro.
## Se MISD dovremmo salvare tutto in una matrice magari, un dataset in pratica, con ogni
## riga i-esima che si riferisce ai parameteri per l'utente i-esimo.
## Comunque una volta fatto, si passano quei risultati a una funzione compute_score(...).
## E da quella ci siamo.


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
    if key == "callme"
        set_player_data(player_id, :player_name, val)
        return "Game parameters updated."
    elseif key == "play"
        set_player_data(player_id, :state, val)
        return "Game parameters updated."
    else
        val_num = parse(Float64,val)
        if 0<=val_num<=100
            set_player_data(player_id, Symbol(key), val_num)
            return "Game parameters updated."
        else
            return "Give a value in [0,100]."
        end
    end
end

function handle_command(msg)
    chat_id = msg.message.chat.id
    player_id = chat_id
    if !is_player_registered(player_id)
        register_player(player_id)
    end
    
    name = msg.message.from.first_name    
    username = msg.message.from.username    
    who="dear"
    if name != ""
        who=name
    end
    if username != ""
        who=username
    end

    if who=="dear"
        sendMessage(tg,
        text="Telegram does not let me know who you are! Use \"callme ...\" syntax to tell us how should I call you. We need it for setupping the final scoreboard.",
        chat_id=chat_id)
    else
        set_player_data(player_id, :player_name, who)
    end
    
    if msg.message.text == "/start"
        @show chat_id
        sendMessage(tg,
            text="Hello $(who)!\nTechnically, you for me are $chat_id",
            chat_id=chat_id)


    elseif msg.message.text == "/help"
        sendMessage(tg,
            text=print_help(),
            chat_id = chat_id,
            parse_mode="Markdown")


    elseif msg.message.text == "/state"
        to_send = """
            Choose the state you want to play with. These are the possibilities:
             HRV -> Croatia
             CZE -> Czech Republic
             DNK -> Denmark
             EST -> Estonia
             FIN -> Finland
             FRA -> France
             GRC -> Greece
             HUN -> Hungary
             LTU -> Lithuania
             LUX -> Luxembourg
             POL -> Poland
             SVK -> Slovakia
             SVN -> Slovenia
             ESP -> Spain"""
        sendMessage(tg,
            text=to_send,
            chat_id = chat_id)


    elseif msg.message.text == "/budget"
        to_send = """
            Choose how you want to manage your budget. How much do you want to invest on the following categories?
             tec -> technology
             psi -> psychology
             clt -> culture
             fam -> family
             tch -> teacher
             sch -> school
           Give a value between 0 and 100 for each category; the values should add up to 100 but don't worry for possile mistakes, we will fix them, if any, normalizing everything to 1."""
        sendMessage(tg,
            text=to_send,
            chat_id = chat_id)


    # just a random test with numbers
    elseif match(r"^[0-9 \.]+$", msg.message.text) !== nothing
        x = parse.(Float64, split(msg.message.text, " "))
        sendMessage(tg,
            text = "Your number squared is $(x.^2)",
            chat_id=chat_id)


    elseif length(split(msg.message.text," "))==2
        if is_valid_keyword(split(msg.message.text," ")[1])
            ## we are in the "keyword value" case
            ## so we get our data here
            sendMessage(tg,
                # text = "Parameters game updated.",
                text = process_keyword_value(msg.message.text, player_id),
                chat_id=chat_id)
        else
            sendMessage(tg,
                text = "I didnt manage to parse your input correctly.\nSo I will cowardly ignore your message.",
                chat_id=chat_id)
        end

    else
        sendMessage(tg,
            text = "I didnt manage to parse your input correctly.\nSo I will cowardly ignore your message.",
            chat_id=chat_id)

    end
end


function main()
    run_bot() do msg
        @show msg
        @show df
            handle_command(msg)
    end
end

# Avvia il bot
main()