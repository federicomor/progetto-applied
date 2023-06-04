using Telegram, Telegram.API
using ConfigEnv

dotenv()
# sendMessage(text = "Ready.")
println(getMe())

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
        # Invia il messaggio di risposta con il chat_id
        @show chat_id
        sendMessage(tg,text="Hello $(who)!",chat_id=chat_id)
    elseif match(r"^[0-9 \.]+$", msg.message.text) !== nothing
        x = parse.(Float64, split(msg.message.text, " "))
        sendMessage(tg,text = "Your number squared is $(x.^2)", chat_id=chat_id)
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