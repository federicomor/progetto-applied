using Telegram, Telegram.API
using ConfigEnv

############# Debug stuff #############
dotenv()
println(getMe())

BOT_API = "6203755027:AAFvDKYwPUSFJeOHs97fjjpuzk2vF9kBaws"
tg = TelegramClient(BOT_API)


############# Game variables #############
USER = ""
USER_STATE = ""
USER_BUDGET = Dict("tec"=>-1, "psi"=>-1, "clt"=>-1, "fam"=>-1, "tch"=>-1, "sch"=>-1)
# access value with BUDGET["cat"], is like a map


############# Global const variables #############
STATES = ["HRV" "CZE" "DNK" "EST" "FIN" "FRA" "GRC"
          "HUN" "LTU" "LUX" "POL" "SVK" "SVN" "ESP"]
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

    Keywords are: _callme, play, tec, psi, clt, fam, tch, sch_. Values should be: a string (for the state and callme) or a number (for the budget). All is case-insensitive, so play or Play won't get the bot crash, for example.
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


# function build_keyboard_state()
#     keyboard = Vector{Vector{String}}()
#     push!(keyboard,["HRV"])
#     push!(keyboard,["CZE"])
#     push!(keyboard,["DNK"])
#     push!(keyboard,["EST"]) 
#     push!(keyboard,["FIN"])
#     push!(keyboard,["FRA"])
#     push!(keyboard,["GRC"])
#     push!(keyboard,["HUN"]) 
#     push!(keyboard,["LTU"])
#     push!(keyboard,["LUX"]) 
#     push!(keyboard,["POL"])
#     push!(keyboard,["SVK"]) 
#     push!(keyboard,["SVN"])
#     push!(keyboard,["ESP"])
#     return Dict(:keyboard => keyboard, :one_time_keyboard => true)
# end


# Funzione per gestire i comandi ricevuti
function handle_command(msg)
    # Ottieni l'ID della chat corrente
    chat_id = msg.message.chat.id
    curr_update_id = msg.update_id
    
    name = msg.message.from.first_name    
    username = msg.message.from.username    
    who="dear"
    if username != ""
        who=username
    end
    if name != ""
        who=name
    end
        
    if msg.message.text == "/start"
        @show chat_id
        sendMessage(tg,
            text="Hello $(who)!\nTechnically, you for me are $chat_id",
            chat_id=chat_id)

        if who!="dear"
            USER = who
        else
            USER = chat_id
        end

        if who=="dear"
            sendMessage(tg,
            text="Telegram does not let me know who you are! Unless you want to be called user_$chat_id, use \"callme ...\" syntax to tell how should I call you. We need it for setupping the final scoreboard.",
            chat_id=chat_id)
        end

    elseif msg.message.text == "/help"
        sendMessage(tg,
            text=print_help(),
            chat_id = chat_id,
            parse_mode="Markdown")

    # elseif msg.message.text == "/state"
    #     sendMessage(tg,
    #         text="Choose the state you want to play with.",
    #         reply_markup = build_keyboard_state(),
    #         chat_id = chat_id)    

    elseif msg.message.text == "/state"
        sendMessage(tg,
            text="Choose the state you want to play with. These are the possibilities:\n\nTODO ELENCO",
            chat_id = chat_id)

    elseif msg.message.text == "/budget"
        sendMessage(tg,
            text="Choose how you want to manage your budget. How much do you want to invest on the following categories?\nGive a value between 0 and 100 to reflect your \"trust\" in it; the values should add up to 100 but dont worry for possile mistakes, later we will take care and normalize everything to 1\n\nTODO ELENCO",
            chat_id = chat_id)

        # for cat in CATEGORIES
        #     out = sendMessage(tg,
        #         text="$cat:",
        #         chat_id = chat_id)
        # end

        ## come ricevere una risposta? forse gestendo gli update_id? 
        ## che sembrano essere sequenziali.
        ## Forse meglio semplicemente fare comandi /psi /tec ecc da usare
        ## nella forma /comando valore, e filtrare il valore
        ## Idem sopra, /state stato, anziché complicare troppo con la keyboard

    # just a random test with numbers
    elseif match(r"^[0-9 \.]+$", msg.message.text) !== nothing
        x = parse.(Float64, split(msg.message.text, " "))
        sendMessage(tg,
            text = "Your number squared is $(x.^2)",
            chat_id=chat_id)

    # elseif msg.message.text in STATES
    #     sendMessage(tg,
    #         text = "State chosen: $(msg.message.text)",
    #         chat_id=chat_id)
    #     STATE_CHOICE = msg.message.text

    elseif length(split(msg.message.text," "))==2
        if is_valid_keyword(split(msg.message.text," ")[1])
            ## we are in the "keyword value" case
            ## so we get our data here
            sendMessage(tg,
                text = "Got your parameter game for keyword _$(split(msg.message.text," ")[1])_",
                chat_id=chat_id,
                parse_mode="Markdown")
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
            handle_command(msg)
    end
end

# Avvia il bot
main()