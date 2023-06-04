using Telegram, Telegram.API
using ConfigEnv

############# Debug stuff #############
dotenv()
println(getMe())

BOT_API = "6203755027:AAFvDKYwPUSFJeOHs97fjjpuzk2vF9kBaws"
tg = TelegramClient(BOT_API)


############# Game variables #############
USER = ""
STATE_CHOICE = ""
BUDGET = Dict("tec"=>-1, "psi"=>-1, "clt"=>-1, "fam"=>-1, "tch"=>-1, "sch"=>-1)
# access value with BUDGET["cat"], is like a map


############# Global variables #############
STATES = ["HRV" "CZE" "DNK" "EST" "FIN" "FRA" "GRC"
          "HUN" "LTU" "LUX" "POL" "SVK" "SVN" "ESP"]
CATEGORIES = ["tec" "psi" "clt" "fam" "tch" "sch"]
WAIT_FOR_UPDATE = 0


############# Real program #############
function print_help()
    str = "help to be written"
    return str
end


function build_keyboard_state()
    keyboard = Vector{Vector{String}}()
    push!(keyboard,["HRV"])
    push!(keyboard,["CZE"])
    push!(keyboard,["DNK"])
    push!(keyboard,["EST"]) 
    push!(keyboard,["FIN"])
    push!(keyboard,["FRA"])
    push!(keyboard,["GRC"])
    push!(keyboard,["HUN"]) 
    push!(keyboard,["LTU"])
    push!(keyboard,["LUX"]) 
    push!(keyboard,["POL"])
    push!(keyboard,["SVK"]) 
    push!(keyboard,["SVN"])
    push!(keyboard,["ESP"])
    return Dict(:keyboard => keyboard, :one_time_keyboard => true)
end


# Funzione per gestire i comandi ricevuti
function handle_command(msg, WAIT_FOR_UPDATE)
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

        # if who=="dear"
        #     sendMessage(tg,
        #     text="Telegram does not let me know who you are!\nPlease type \"Call me\" to tell me your name. I need it for setupping the finak scoreboard.",
        #     chat_id=chat_id)
        # end

    elseif msg.message.text == "/help"
        sendMessage(tg,
            text=print_help(),
            reply_markup = build_keyboard_state(),
            chat_id = chat_id)

    elseif msg.message.text == "/state"
        sendMessage(tg,
            text="Choose the state you want to play with.",
            reply_markup = build_keyboard_state(),
            chat_id = chat_id)

    elseif msg.message.text == "/budget"
        sendMessage(tg,
            text="Choose how you want to manage your budget. How much do you want to invest on the following categories?\nGive a value between 0 and 100 to reflect your \"trust\" in it, later we will normalize everything to 1.",
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

    elseif msg.message.text in STATES
        sendMessage(tg,
            text = "State chosen: $(msg.message.text)",
            chat_id=chat_id)
        STATE_CHOICE = msg.message.text

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