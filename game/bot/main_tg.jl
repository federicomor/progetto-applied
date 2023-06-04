using Telegram, Telegram.API
using ConfigEnv

dotenv()

sendMessage(text = "Ready.")

println(getMe())

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

    # @show message
    # @show chat
    poll_id = 0
    
    if match(r"^[0-9 \.]+$", text) !== nothing
        # x = parse.(Float64, split(text, " "))
        sendMessage(text = "Scelta interessante")
        # sendDice()

        # poll_obj = sendPoll(question="Which state do you want to play with?",
        # 		 options=["ESP","CKW","ENG"])
        # @show getUpdates()
        # poll_id = get(poll_obj, :message_id, nothing)
        # @show poll_id


        # after chat gpt consulence

		# Crea un poll con le opzioni specificate
		scelte = ["Opzione 1", "Opzione 2", "Opzione 3"]
		poll_message = "Scegli un'opzione:"
		poll_result = sendPoll(question=poll_message, options=scelte)

		# Ottieni l'ID del poll
		@show poll_result
		@show get(poll_result,:id,nothing)
		@show poll_result["poll"] # questo funziona!
		
		# Aspetta un po' di tempo per consentire alle persone di
		# rispondere al poll (ad esempio, 60 secondi)
		sleep(10)

		# # Ottieni i risultati del poll
		# poll_results = getPollResults(bot, poll_id)

		# # Esegui le operazioni desiderate con i risultati
		# for (option, result) in zip(options, poll_results.result)
		#     option_text = option
		#     result_count = result.voter_count
		#     println("$option_text: $result_count voti")
		# end



    else
        sendMessage(text = "Please insert a number")
    end
	# result = stopPoll(message_id=poll_id)
    # @show result

end