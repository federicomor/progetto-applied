function is_player_registered(player_id)
    return player_id in df.player_id
end

function register_player(player_id, player_name="missing")
    push!(df, Dict(:player_id => player_id, :player_name => player_name,
                :state => "missing",
                :tec=>Float64(0),:psi=>Float64(0),:clt=>Float64(0),
                :fam=>Float64(0),:tch=>Float64(0),:sch=>Float64(0),
                :score => Float64(0), :zdone => Int64(0)))
end

# set_player_data(1234,:player_name,"Gio")
function set_player_data(player_id, field::Symbol, value)
    # if !is_player_registered(player_id)
    #     register_player(player_id)
    # end
    df[findfirst(isequal.(df.player_id,player_id)),field] = value
end

function get_player_data(player_id, field::Symbol)
    # get_player_data(id,:state)
    if is_player_registered(player_id)
        return df[findfirst(isequal.(df.player_id,player_id)),field]
    end
    return NaN
end
function get_player_data(player_id, field::String)
    # get_player_data(id,"state")
    if is_player_registered(player_id)
        return df[findfirst(isequal.(df.player_id,player_id)),Symbol(field)]
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
    include("get_sol.jl") # this let the dictionary sol available here

    score = 0
    position = findfirst(isequal.(df.player_id,player_id))
    state = df[position, :state]
    method = "canberra"

    for categ in CATEGORIES
        proposto = df[position,"$categ"]
        giusto = sol["$state"]["$categ"]
        score += score_fun(proposto,giusto,method)
    end

    if method=="canberra"
        score = score/6*100
    end

    set_player_data(player_id,:score,score)
end


function summary_player(player_id)
    df_player = df[findfirst(isequal.(df.player_id,player_id)),:]
        # player_id = $(df_player[3])
    to_send = """
        player_name = $(df_player[4] =="missing" ? "NA" : df_player[4])
        state = $(df_player[8]=="missing" ? "NA" : df_player[8])
        tec = $(round(df_player[10],digits=3))
        psi = $(round(df_player[5],digits=3))
        clt = $(round(df_player[1],digits=3))
        fam = $(round(df_player[2],digits=3))
        tch = $(round(df_player[9],digits=3))
        sch = $(round(df_player[6],digits=3))
        done? = $(df_player[11]==1 ? "yes" : "not yet")"""
        # Fill all the NAs to setup your game!
    return to_send
end
