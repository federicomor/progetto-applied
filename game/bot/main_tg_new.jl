using Telegram, Telegram.API
using ConfigEnv
using DataFrames

# https://dataframes.juliadata.org/stable/man/basics/

############# Debug stuff #############
dotenv()
println(getMe())

BOT_API = "6203755027:AAFvDKYwPUSFJeOHs97fjjpuzk2vF9kBaws"
tg = TelegramClient(BOT_API)


############# Game variables #############
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

function set_player_data(player_id, field::Symbol, value)
    # set_player_data(1234,:player_name,"Gio")
    if !is_player_registered(player_id)
        register_player(player_id)
    end
        df[findfirst(isequal.(df.player_id,player_id)),field] = value
end


############# Global const variables #############
STATES = [ "HRV" "CZE" "DNK" "EST" "FIN" "FRA" "GRC" "HUN" "LTU" "LUX" "POL" "SVK" "SVN" "ESP" ]

FULL_STATES = Dict(
    "HRV"=>"name",
    "CZE"=>"name",
    "DNK"=>"name",
    "EST"=>"name",
    "FIN"=>"name",
    "FRA"=>"name",
    "GRC"=>"name",
    "HUN"=>"name",
    "LTU"=>"name",
    "LUX"=>"name",
    "POL"=>"name",
    "SVK"=>"name",
    "SVN"=>"name",
    "ESP"=>"name" )

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


function filter_value_to_Number(text, T::DataType)
    # function to get the value in the string of the form "/command value"
    # filter_value("psi 13",Int64) -> 13
    # filter_value("psi 13",Float64) -> 13.0
    target = split(text," ")[1]
    value = split(text," ")[2]
    return (target,parse(T, value))
end

function filter_value_to_String(text)
    target = split(text," ")[1]
    value = split(text," ")[2]
    return (target,value)
end

function is_valid_keyword(text)
    if lowercase(text) in KEYWORDS
        return true
    end
    # handle case where user put a slash before, /psi, /play, ecc
    if lowercase(text[2:end]) in KEYWORDS
        return true
    end
    return false
end

function handle_command(msg)
    chat_id = msg.message.chat.id
    if !is_player_registered(chat_id)
        register_player(chat_id)
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
        sendMessage(tg,
            text="Choose the state you want to play with. These are the possibilities:\n\nTODO ELENCO",
            chat_id = chat_id)


    elseif msg.message.text == "/budget"
        sendMessage(tg,
            text="Choose how you want to manage your budget. How much do you want to invest on the following categories?\nGive a value between 0 and 100 for each category; the values should add up to 100 but don't worry for possile mistakes, we will fix them, if any, normalizing everything to 1.\n\nTODO ELENCO",
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
                text = "Parameters game updated.",
                chat_id=chat_id)
            # process value
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