using GLM
using StatsModels
using Statistics

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
            df[position,Symbol(categ)] /= (tot) #/100)
        end
    end
end

function score_fun(proposto,giusto,method::String)
    if method=="canberra"
        return 1 - abs((proposto-giusto)/(proposto+giusto))
        # max punteggio 6, min punteggio dipende
    end
end

############# Creazione fit #############
data = DataFrame(CSV.File("data_woo.csv"))
v = names(data)
cnames =replace.(v,"."=>"_")
rename!(data, Symbol.(cnames))
FORMULA_social = @formula(
    Social_well_being ~
    Approach_to_ICT+
    Use_of_ICT+
    Teachers__degree+
    Teacher_skill+
    ESCS+
    RATCMP1+
    ICTSCH+
    HEDRES+
    STUBEHA+
    ATTLNACT+
    JOYREAD+
    PROAT6+
    CLSIZE+
    EDUSHORT+
    STAFFSHORT+
    PV1MATH+
    PV1READ+
    CNT+
    IM_PUBLIC)
# FORMULA_psych = @formula(
#     Psychological_well_being ~
#     Approach_to_ICT+
#     Use_of_ICT+
#     Teachers__degree+
#     Teacher_skill+
#     ESCS+
#     RATCMP1+
#     ICTSCH+
#     HEDRES+
#     STUBEHA+
#     ATTLNACT+
#     JOYREAD+
#     PROAT6+
#     CLSIZE+
#     EDUSHORT+
#     STAFFSHORT+
#     PV1MATH+
#     PV1READ+
#     CNT+
#     IM_PUBLIC)
lmodel = lm(FORMULA_social,data)
############# end #############


function compute_score(player_id)
    normalize_player_data(player_id)
    score = 0
    ############# start prediction #############
    new_obs = 1 # intercetta

    new_obs = [new_obs quantile(data.Approach_to_ICT,get_player_data(player_id,"tec")) ]
    new_obs = [new_obs quantile(data.Use_of_ICT,get_player_data(player_id,"tec")) ]
    new_obs = [new_obs quantile(data.Teachers__degree,get_player_data(player_id,"tch")) ]
    new_obs = [new_obs quantile(data.Teacher_skill,get_player_data(player_id,"tch")) ]
    new_obs = [new_obs quantile(data.ESCS,get_player_data(player_id,"fam")) ]
    new_obs = [new_obs quantile(data.RATCMP1,get_player_data(player_id,"tec")) ]
    new_obs = [new_obs quantile(data.ICTSCH,get_player_data(player_id,"tec")) ]
    new_obs = [new_obs quantile(data.HEDRES,get_player_data(player_id,"fam")) ]
    new_obs = [new_obs quantile(data.STUBEHA,get_player_data(player_id,"stu")) ]
    new_obs = [new_obs quantile(data.ATTLNACT,get_player_data(player_id,"stu")) ]
    new_obs = [new_obs quantile(data.JOYREAD,get_player_data(player_id,"stu")) ]
    new_obs = [new_obs quantile(data.PROAT6,get_player_data(player_id,"tch")) ]
    new_obs = [new_obs quantile(data.CLSIZE,get_player_data(player_id,"sch")) ]
    new_obs = [new_obs quantile(data.EDUSHORT,get_player_data(player_id,"sch")) ]
    new_obs = [new_obs quantile(data.STAFFSHORT,get_player_data(player_id,"sch")) ]
    new_obs = [new_obs quantile(data.PV1MATH,get_player_data(player_id,"stu")) ]
    new_obs = [new_obs quantile(data.PV1READ,get_player_data(player_id,"stu")) ]

    new_obs = [new_obs get_player_data(player_id,"state") == "DNK"]
    new_obs = [new_obs get_player_data(player_id,"state") == "ESP"]
    new_obs = [new_obs get_player_data(player_id,"state") == "EST"]
    new_obs = [new_obs get_player_data(player_id,"state") == "FIN"]
    new_obs = [new_obs get_player_data(player_id,"state") == "FRA"]
    new_obs = [new_obs get_player_data(player_id,"state") == "GRC"]
    new_obs = [new_obs get_player_data(player_id,"state") == "HRV"]
    new_obs = [new_obs get_player_data(player_id,"state") == "HUN"]
    new_obs = [new_obs get_player_data(player_id,"state") == "LTU"]
    new_obs = [new_obs get_player_data(player_id,"state") == "LUX"]
    new_obs = [new_obs get_player_data(player_id,"state") == "POL"]
    new_obs = [new_obs get_player_data(player_id,"state") == "SVK"]
    new_obs = [new_obs get_player_data(player_id,"state") == "SVN"]

    new_obs = [new_obs quantile(data.IM_PUBLIC,1-get_player_data(player_id,"sch")) ]

    score = predict(lmodel,new_obs)[1]
    score += 2*abs(minumum(data.Social_well_being))
    # shift perché lo scoreboard non riesce a plottare valori negativi
    ############# end #############
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
