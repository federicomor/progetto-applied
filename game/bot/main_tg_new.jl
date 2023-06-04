using Telegram, Telegram.API
using ConfigEnv

dotenv()
println(getMe())

STATES = ["HRV" "CZE" "DNK" "EST" "FIN" "FRA" "GRC" "HUN" "LTU" "LUX" "POL" "SVK" "SVN" "ESP"]


function build_keyboard()
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
    return Dict(:keyboard => keyboard, :one_time_keyboard => false)
end

# Inizializza il bot con il tuo token API
BOT_API = "6203755027:AAFvDKYwPUSFJeOHs97fjjpuzk2vF9kBaws"
tg = TelegramClient(BOT_API)

# Funzione per gestire i comandi ricevuti
function handle_command(msg)
    # Ottieni l'ID della chat corrente
    chat_id = msg.message.chat.id
    
    name = msg.message.from.first_name    
    username = msg.message.from.username    
    who="dear"
    if username != ""
        who=username
    end
    if name != ""
        who=name
    end
        
    # Verifica se il comando è "/start"
    if msg.message.text == "/start"
        @show chat_id
        sendMessage(tg,
            text="Hello $(who)!\nTechnically, you for me are $chat_id",
            chat_id=chat_id)

    elseif msg.message.text == "/state"
        sendMessage(tg,
            text="Choose you weapon (state):",
            reply_markup = build_keyboard(),
            chat_id = chat_id)

    elseif msg.message.text == "/budget"
        sendMessage(tg,
            text="in progress",
            chat_id = chat_id)

    elseif match(r"^[0-9 \.]+$", msg.message.text) !== nothing
        x = parse.(Float64, split(msg.message.text, " "))
        sendMessage(tg,
            text = "Your number squared is $(x.^2)",
            chat_id=chat_id)

    elseif msg.message.text in STATES
        sendMessage(tg,
            text = "State chosen: $(msg.message.text)",
            chat_id=chat_id)

    else
        sendMessage(tg,
            text = "I will cowardly ignore your message.",
            chat_id=chat_id)

    end
end

# Funzione per avviare il bot e gestire i messaggi
function main()
    run_bot() do msg
        # Gestisci solo i messaggi di testo
        # if msg.message isa Telegram.TextMessage
        @show msg
            handle_command(msg)
        # end
    end
end

# Avvia il bot
main()