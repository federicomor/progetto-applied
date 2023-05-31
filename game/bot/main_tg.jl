using Telegram, Telegram.API
using ConfigEnv

dotenv()

# sendMessage(text = "Hello world")

# println(tg.getMe())

# open("picture.png", "r") do io
#     sendPhoto(photo = io)
# end

# run_bot() do msg
#     message = get(msg, :message, nothing)
#     message === nothing && return nothing
#     text = get(message, :text, "")
#     chat = get(message, :chat, nothing)
#     chat === nothing && return nothing
#     chat_id = get(chat, :id, nothing)
#     chat_id === nothing && return nothing
    
#     if match(r"^[0-9 \.]+$", text) !== nothing
#         x = parse.(Float64, split(text, " "))
#         sendMessage(text = "your input squared is $(x.^2)")
#     else
#         sendMessage(text = "Unknown command")
#     end
# end

run_bot() do msg
    message = get(msg, :message, nothing)
    message === nothing && return nothing
    text = get(message, :text, "")
    chat = get(message, :chat, nothing)
    chat === nothing && return nothing
    chat_id = get(chat, :id, nothing)
    chat_id === nothing && return nothing
    
    if match(r"^[0-9 \.]+$", text) !== nothing
        x = parse.(Float64, split(text, " "))
        sendMessage(text = "Ricevuto, siamo operativi")
        sendDice()

        sendPoll(question="Which state do you want to play with",
        		 options=["ESP","CKW","ENG"])
    else
        sendMessage(text = "Unknown command")
    end
end