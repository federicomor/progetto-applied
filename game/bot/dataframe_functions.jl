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
data = DataFrame(CSV.File("very_last_dataset.csv"))

v = names(data)
cnames =replace.(v,"."=>"_")
rename!(data, Symbol.(cnames))

FORMULA_social_LMM = @formula(
    Social_well_being ~
    CompInt_ICT+ Teacher_skills+ ENTUSE+ ATTLNACT+ LM_MINS+ PROAT5AM+
    PV1READ+ HEDRES + JOYREAD + RATCMP1 + EDUSHORT+ 
    (1|CNT))

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
        "Social_well_being" => 0, # julia vuole la response column inizializzata a qualcosa

        "CompInt_ICT" => quantile(data[:,:CompInt_ICT],
            min(get_player_data(player_id,"tec")/100+0.5,1)),
        "Teacher_skills" => quantile(data[:,:Teacher_skills],
            min(get_player_data(player_id,"tch")/100+0.5,1)),
        "ENTUSE" => mean(data[:,:ENTUSE]),
        "ATTLNACT" => mean(data[:,:ATTLNACT]),
        "LM_MINS" => quantile(data[:,:LM_MINS],
            min(get_player_data(player_id,"stu")/100+0.5,1)),
        "PROAT5AM" => quantile(data[:,:PROAT5AM],
            min(get_player_data(player_id,"tch")/100+0.5,1)),
        "PV1READ" => quantile(data[:,:PV1READ],
            min(get_player_data(player_id,"stu")/100+0.5,1)),
        "HEDRES" => quantile(data[:,:HEDRES],
            min(get_player_data(player_id,"fam")/100+0.5,1)),
        "JOYREAD" => mean(data[:,:JOYREAD]),
        "RATCMP1" => quantile(data[:,:RATCMP1],
            min(get_player_data(player_id,"tec")/100+0.5,1)),
        "EDUSHORT" => quantile(data[:,:EDUSHORT],
            min(get_player_data(player_id,"sch")/100+0.5,1)),

        "CNT" => get_player_data(player_id,"state")
    )
    nobs_LMM = DataFrame(nobs_LMM)
    score_LMM = predict(lmmodel,nobs_LMM)[1]

    # se vogliamo pesare di più la scelta dello stato
    # score_LMM += raneff[raneff.CNT .== get_player_data(player_id,"state"),:Intercept][1]

    ## Update: aggiusta tutto dopo quando fa il grafico
    ############# end #############
    return score_LMM
end




function summary_player(player_id)
    df_player = df[findfirst(isequal.(df.player_id,player_id)),:]
    
    amount_invested = get_amount_invested(player_id)
    str_return = "Total amount invested: $(round(amount_invested,digits=2)) "
    if amount_invested>100
        str_return *= "(amount>100, we will normalize everything later, dont worry, or fix now by inserting lower amounts) "
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
