function is_player_registered(player_id)
    return player_id in df.player_id
end

function register_player(player_id, player_name="missing")
    push!(df, Dict(:player_id => player_id, :player_name => player_name,
                :state => "missing",
                :tec=>Float64(0),:tch=>Float64(0),:sch=>Float64(0),
                :stu=>Float64(0),:fam=>Float64(0),
                :score => Float64(0), :zdone => Int64(0)))
end

# set_player_data(1234,:player_name,"Gio")
function set_player_data(player_id, field::Symbol, value)
    # if !is_player_registered(player_id)
    #     register_player(player_id)
    # end
    try
        df[findfirst(isequal.(df.player_id,player_id)),field] = value
    catch e
        @show e
    end
end

function get_amount_invested(player_id)
    somma = 0
    for cat in CATEGORIES
        somma += get_player_data(player_id, cat)
    end
    return somma
end

function get_player_data(player_id, field::Symbol)
    # get_player_data(id,:state)
    try
        if is_player_registered(player_id)
            return df[findfirst(isequal.(df.player_id,player_id)),field]
        end
    catch e
        @show e
    end
    return NaN
end
function get_player_data(player_id, field::String)
    # get_player_data(id,"state")
    try
        if is_player_registered(player_id)
            return df[findfirst(isequal.(df.player_id,player_id)),Symbol(field)]
        end
    catch e
        @show e
    end
    return NaN
end


function normalize_player_data(player_id)
    # if !is_player_registered(player_id)
        # register_player(player_id)
    # end
    tot = 0
    position = findfirst(isequal.(df.player_id,player_id))

    for categ in CATEGORIES
        tot += df[position,Symbol(categ)]
    end
    if tot != 0
        for categ in CATEGORIES
            df[position,Symbol(categ)] /= (tot/100)
        end
    end
end

function score_fun(proposto,giusto,method::String)
    if method=="canberra"
        return 1 - abs((proposto-giusto)/(proposto+giusto))
        # max punteggio 6, min punteggio dipende
    end
end

function compute_score(player_id)
    normalize_player_data(player_id)

    ############# START #############
    

    ############# END #############
    
    set_player_data(player_id,:score,score)
end


function summary_player(player_id)
    df_player = df[findfirst(isequal.(df.player_id,player_id)),:]
        # player_id = $(df_player[3])
    to_send = """
        player_name = $(df_player[3] =="missing" ? "NA" : df_player[3])
        state = $(df_player[6]=="missing" ? "NA" : df_player[6])
        tec = $(round(df_player[9],digits=3))
        tch = $(round(df_player[8],digits=3))
        sch = $(round(df_player[4],digits=3))
        stu = $(round(df_player[7],digits=3))
        fam = $(round(df_player[1],digits=3))
        done? = $(df_player[10]==1 ? "yes" : "not yet")"""
        # Fill all the NAs to setup your game!
    return to_send
end
