using Telegrambot
botApi = "bot6203755027:AAFvDKYwPUSFJeOHs97fjjpuzk2vF9kBaws"

welcomeMsg(incoming::AbstractString, params::Dict{String,Any}) = "Welcome to my awesome bot @" * string(params["from"]["username"]) 

echo(incoming::AbstractString, params::Dict{String,Any}) = incoming

txtCmds = Dict()
txtCmds["repeat_msg"] = echo #this will respond to '/repeat_msg <any thing>'
txtCmds["start"] = welcomeMsg # this will respond to '/start'

txtCmdsMessage = Dict()
txtCmdsMessage["start_response"] = welcomeMsg #this will quote reply to a message respond to '/start_response' 

inlineOpts = Dict() #Title, result pair
inlineOpts["Make Uppercase"] = uppercase #this will generate an pop-up named Make Uppercase and upon tapping return uppercase(<user_input>)

#uppercase is a function that takes a string and return the uppercase version of that string

startBot(botApi; textHandle = txtCmds, textHandleReplyMessage = txtCmdsMessage, inlineQueryHandle=inlineOpts)