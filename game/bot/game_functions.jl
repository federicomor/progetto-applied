function print_help(chat_id)
    str1 = """
    *Idea of the game*
    The PISA dataset that we had contained data gathered from questionnaires compiled by children in mid schools. We grouped all those data into different categories and with our statistical analysis we were able to sort out not only in which states there were the better schools, in terms of general well-being of the students, but also which impact those categories have, singularly, in the final position of the state in the ranking, together with the effect of the state itself.

    So we setup a game, a bit similar to Risiko or Monopoli: you have to choose your character, the state to play with, and how to spend your budget on the various categories, like if you were the "Minister of Education" in that state. 

    We will then rank your choice and build up a global scoreboard with also everyone else who will play the game."""

    str2 = """
    *Instructions to play the game*
    (1) Type /start to get the welcome message.
    (2) Type /help to read again the instructions.
    (2) Type /state to choose the state to play with.
    (3) Type /budget to implement your strategy.
    (4) Type /summary to see your game parameters.
    (5) Type "/done yes" to confirm your parameters choice.
    (6) Type /results to see your position in the ranking!"""

    # str3 = """
    # *Game parameters*
    # To set your game parameters send a message in the form "*keyword value*": keyword identifies the parameter, and value sets it according to your choice.
    # For example:
    # - "play ESP" selects ESP as the state to play with
    # - "tec 40" selects to invest 40% of your budget on category technology
    # - "callme Jhonny" selects your username to be Jhonny

    # Keywords are: _callme, play, tec, stu, fam, tch, sch_.
    # Values should be: a string (for the state and callme) or a number (for the budget).
    # All is case-insensitive, so callme or Callme or CallMe will all work.
    # """

    str3 = """
    *Game parameters*
    To set your game parameters send a message in the form "*keyword value*".
    You will understand better this method in the following sections (/state and /budget), but for example a keyword is _callme_, so you can send a message with _callme Jhonny_ to set your player name as Jhonny. 
    """

    # useremo la funzione lowercase(input) ovunque
    sendMessage(tg,
            text=str1,
            chat_id = chat_id,
            parse_mode="Markdown")
        sendMessage(tg,
            text=str2,
            chat_id = chat_id,
            parse_mode="Markdown")
        sendMessage(tg,
            text=str3,
            chat_id = chat_id,
            parse_mode="Markdown")
    
end


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
    if (lowercase(text) in KEYWORDS) || ( (lowercase(text[2:end]) in KEYWORDS) && (text[1]=='/') )
        return true
    end
    return false
end

function which_keyword(text)
    key = split(text," ")[1]
    if key[1]=='/'
        key = key[2:end]
    end
    return KEYWORDS[findfirst(isequal.(KEYWORDS,lowercase(key)))[2]]
end

function process_keyword_value(text, player_id)
    key = which_keyword(text)
    val = split(text," ")[2]
    # done = df[findfirst(isequal.(df.player_id,player_id)),:zdone]
    done = 0 # always admit changes

    if key == "callme" && done==0
        # maybe one can still change his/her player_name even after /done
        if in(val,df[:,:player_name])
            return "Error: name already taken."
        else
            set_player_data(player_id, :player_name, replace(val,r"\n+"=>""))
            # return "Game parameters updated.\nSee them with /summary."
            return summary_player(player_id)
        end
    elseif key == "play" && done==0
        if uppercase(val) in STATES || val in STATES
            set_player_data(player_id, :state, uppercase(val))
            # return "Game parameters updated.\nSee them with /summary."
            str_return = summary_player(player_id)
            return str_return
        else
            return "Error: give a correct state acronym.\nSee /state for the possibilities."
        end
    elseif key != "play" && key != "callme" && done==0
        val_num = 0
        try 
            val_num = parse(Float64,val)
        catch e
            # return "Error: $e"
            return "Error: $(e.msg)"
        end
        if 0<=val_num<=100
            set_player_data(player_id, Symbol(key), val_num)
            # normalize_player_data(player_id)
            # return "Game parameters updated.\nSee them with /summary."
            str_return = summary_player(player_id)
            return str_return
        else
            return "Error: give a value in [0,100]."
        end
    else
        return "You can't change anymore your game parameters."
    end

    return "Something went wrong here."
end


function bcast(msg_text)
    for idd in df.player_id
        try
            sendMessage(tg,
                text = msg_text,
                chat_id=idd)
        catch e
            @show e
        end
    end
end