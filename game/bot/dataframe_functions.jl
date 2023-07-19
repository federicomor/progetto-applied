using GLM
using StatsModels
using Statistics
using CSV
using DataFrames
using MixedModels

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
        # if is_player_registered(player_id)
            return df[findfirst(isequal.(df.player_id,player_id)),field]
        # end
    catch e
        @show e
    end
    return NaN
end
function get_player_data(player_id, field::String)
    # get_player_data(id,"state")
    try
        # if is_player_registered(player_id)
            return df[findfirst(isequal.(df.player_id,player_id)),Symbol(field)]
        # end
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



############# Creazione fit #############
# data = DataFrame(CSV.File("data_social_woo.csv"))
data = DataFrame(CSV.File("data_woo_really_final.csv"))

v = names(data)
cnames =replace.(v,"."=>"_")
rename!(data, Symbol.(cnames))

FORMULA_social_LMM = @formula(
    Social_well_being ~
    CompInt_ICT+ Teacher_skills+ HEDRES+  CULTPOSS+ ATTLNACT+ 
    PROAT5AB+ CLSIZE+ CREACTIV+ SCHSIZE+ PV1READ+ LM_MINS+ ENTUSE
    +(1|CNT))

# Social_well_being ~
#     Approach_to_ICT+ Use_of_ICT+ Teachers__degree+ Teacher_skill+ ESCS+ 
#     RATCMP1+ ICTSCH+ HEDRES+ STUBEHA+ ATTLNACT+ JOYREAD+ PROAT6+ CLSIZE+
#     EDUSHORT+ STAFFSHORT+ PV1MATH+ PV1READ+
#     (1|CNT))


# lmodel = lm(FORMULA_social_LM,data)
lmmodel = fit(MixedModel, FORMULA_social_LMM, data)

rnames = ["CNT","Intercept"]
raneff = DataFrame(only(raneftables(lmmodel)))
rename!(raneff,Symbol.(rnames))
sort!(raneff,:Intercept,rev=true)
############# end #############


function compute_score(player_id)
    global lmodel, data
    normalize_player_data(player_id)
    if get_player_data(player_id,:zdone)==0
        set_player_data(player_id,:zdone,1)
    end

    score = 0
    ############# start prediction #############
    # usare mean(data[:,:ECC]) se vogliamo scartare le variabili che non riteniamo controllabili

    nobs_LMM = Dict(
        "Social_well_being" => 345,
        "Approach_to_ICT" => quantile(data[:,:Approach_to_ICT],get_player_data(player_id,"tec")/100),
        "Use_of_ICT" => quantile(data[:,:Use_of_ICT],get_player_data(player_id,"tec")/100),
        "Teachers__degree" => quantile(data[:,:Teachers__degree],get_player_data(player_id,"tch")/100),
        "Teacher_skill" => quantile(data[:,:Teacher_skill],get_player_data(player_id,"tch")/100),
        "ESCS" => quantile(data[:,:ESCS],get_player_data(player_id,"fam")/100),
        "RATCMP1" => quantile(data[:,:RATCMP1],get_player_data(player_id,"tec")/100),
        "ICTSCH" => quantile(data[:,:ICTSCH],get_player_data(player_id,"tec")/100),
        "HEDRES" => quantile(data[:,:HEDRES],get_player_data(player_id,"fam")/100),
        "STUBEHA" => quantile(data[:,:STUBEHA],get_player_data(player_id,"stu")/100),
        "ATTLNACT" => quantile(data[:,:ATTLNACT],get_player_data(player_id,"stu")/100),
        "JOYREAD" => quantile(data[:,:JOYREAD],get_player_data(player_id,"stu")/100),
        "PROAT6" => quantile(data[:,:PROAT6],get_player_data(player_id,"tch")/100),
        "CLSIZE" => quantile(data[:,:CLSIZE],get_player_data(player_id,"sch")/100),
        "EDUSHORT" => quantile(data[:,:EDUSHORT],get_player_data(player_id,"sch")/100),
        "STAFFSHORT" => quantile(data[:,:STAFFSHORT],get_player_data(player_id,"sch")/100),
        "PV1MATH" => quantile(data[:,:PV1MATH],get_player_data(player_id,"stu")/100),
        "PV1READ" => quantile(data[:,:PV1READ],get_player_data(player_id,"stu")/100),
        "CNT" => get_player_data(player_id,"state")
    )
    nobs_LMM = DataFrame(nobs_LMM)

    # nobs_LM = 1 # intercetta
    # nobs_LM = [nobs_LM quantile(data[:,:Approach_to_ICT],get_player_data(player_id,"tec")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:Use_of_ICT],get_player_data(player_id,"tec")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:Teachers__degree],get_player_data(player_id,"tch")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:Teacher_skill],get_player_data(player_id,"tch")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:ESCS],get_player_data(player_id,"fam")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:RATCMP1],get_player_data(player_id,"tec")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:ICTSCH],get_player_data(player_id,"tec")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:HEDRES],get_player_data(player_id,"fam")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:STUBEHA],get_player_data(player_id,"stu")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:ATTLNACT],get_player_data(player_id,"stu")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:JOYREAD],get_player_data(player_id,"stu")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:PROAT6],get_player_data(player_id,"tch")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:CLSIZE],get_player_data(player_id,"sch")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:EDUSHORT],get_player_data(player_id,"sch")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:STAFFSHORT],get_player_data(player_id,"sch")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:PV1MATH],get_player_data(player_id,"stu")/100) ]
    # nobs_LM = [nobs_LM quantile(data[:,:PV1READ],get_player_data(player_id,"stu")/100) ]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "DNK"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "ESP"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "EST"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "FIN"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "FRA"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "GRC"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "HRV"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "HUN"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "LTU"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "LUX"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "POL"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "SVK"]
    # nobs_LM = [nobs_LM get_player_data(player_id,"state") == "SVN"]
    # nobs_LM = [nobs_LM quantile(data[:,:IM_PUBLIC],1-get_player_data(player_id,"sch")/100) ]

    # score_LM = predict(lmodel,nobs_LM)[1]
    score_LMM = predict(lmmodel,nobs_LMM)[1]

    # score += 2*abs(minimum(data[:,:Social_well_being]))
    # score *= 100
    ## shift perché lo scoreboard non riesce a plottare valori negativi
    ## Update: aggiusta tutto dopo quando fa il grafico
    ############# end #############
    return score_LMM
end




function summary_player(player_id)
    df_player = df[findfirst(isequal.(df.player_id,player_id)),:]
    
    amount_invested = get_amount_invested(player_id)
    str_return = "Total amount invested: $(round(amount_invested,digits=2)) "
    if amount_invested>100
        str_return *= "(amount>100, we will normalize everything later, dont worry, or fix nom by inserting lower amounts) "
    end

    to_send = """
        $str_return
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
