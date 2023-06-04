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


############# Global variables #############
STATES = ["HRV" "CZE" "DNK" "EST" "FIN" "FRA" "GRC"
          "HUN" "LTU" "LUX" "POL" "SVK" "SVN" "ESP"]
CATEGORIES = ["tec" "psi" "clt" "fam" "tch" "sch"]


############# Real program #############
function print_help()
    str = """
    *Idea of the game*
    The PISA dataset that we had contained data gathered from children in mid schools. 
    In it there are lots of different answers, related to the students' contact with technology, their wellbeing and other psychological aspects, the cultural context in which they live in, the relation with their family and with the teachers, and finally the characteristics of the school they attend.

    We grouped those questions into some categories (technology, psychology, culture, familiy, teachers, school), and with our statistical analysis we were able to sort out not only in which states there were the better schools, but also which impact those categories have in the final position of the state in the ranking.

    So we setup a game, a bit similar to Risiko or Monopoli: you have to choose your character, the state to play with, and how to spend/invest your budget, like if you were the "minister of school" in that state. We will then rank your choice and build up a global scoreboard with also everyone else plays the game.

    *Instructions to play the game*
    (1) Type /start for the welcome message.
    (2) Type /state to choose the state to play with.
    (3) Type /budget to implement your strategy.
    (4) Talk with us at our poster section.
    (5) Type /results for your final ranking agains all the players!

    *Command execution*
    Each interactive command expects that you answer in the form *target value* which provides the parameter game you want to define and the value you want to assign. 
    For example "play ESP" correctly selects ESP as the state to play with, "tec 60" correctly selects to invest 60% of your budget on category technology, etc.

    Targets are: whoami, play, tec, psi, clt, fam, tch, sch.
    Values should be: a string (for the state and whoami) or a number (for the budget).
    """
    return str
end


function filter_value(text, value_for_type_conversion)
    # function to get the value in the string of the form "/command value"
    # Esempio: 
    # text = "/psi 13"
    # filter_value(text,0) -> 13
    # filter_value(text,0.232) -> 13.0

    target = split(text," ")[1]
    value = split(text," ")[2]
    return parse(typeof(value_for_type_conversion), value)
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
            text="Telegram does not let me know who you are! Please use \"whoami ...\" syntax to tell me your name. I need it for setupping the final scoreboard.",
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
            text="Choose the state you want to play with. These are the possibilities:\nTODO ELENCO",
            chat_id = chat_id)

    elseif msg.message.text == "/budget"
        sendMessage(tg,
            text="Choose how you want to manage your budget. How much do you want to invest on the following categories? (give a value between 0 and 100 to reflect your \"trust\" in it, the values should add up to 100 but dont worry for possile mistakes, later we will take care and normalize everything to 1)\nTODO ELENCO",
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
        ## we are in the target value case
        ## so we get our data here

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