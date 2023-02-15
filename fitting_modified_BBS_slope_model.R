### creating a slope-only model for comparison with
### a similar eBird model

#setwd("C:/Users/SmithAC/Documents/GitHub/bbsBayes2_modified_slope")

library(bbsBayes2)
library(tidyverse)


model = "slope"
stratification = "latlong"
model_variant = "spatial"
firstYear = 2007
lastYear = 2018


# # copy bbsBayes2 model file to directory
# # only done once, not necessary to repeat
# copy_model_file(model = model,
#                 model_variant = model_variant,
#                 dir = "models")

### The above exported Stan file was modified manually
### to remove or quote-out all uses of the yeareffects parameters
### the resulting file was stored as the slope_only version referenced
### in the next line.
alternate_model_file <- "models/slope_only_spatial_bbs_CV.stan"


sps_to_run <- c("Wood Thrush",
                "Ovenbird",
                "Red-eyed Vireo",
                "Barn Swallow",
                "Baltimore Oriole",
                "Black-capped Chickadee",
                "Carolina Chickadee",
                "American Woodcock",
                "Hairy Woodpecker",
                "Indigo Bunting",
                "Lazuli Bunting",
                "Ruffed Grouse",
                "Upland Sandpiper")

for(species in sps_to_run){
#species = "Red-eyed Vireo"


s <- stratify(by = stratification,
              species = species)

## alternate minimum route-years for AMWO
## however, even with this low number, the strata map is
## a bit ridiculous
if(species == "American Woodcock"){
p <- prepare_data(s,
                  min_n_routes = 1,
                  min_max_route_years = 2,
                  min_year = firstYear,
                  max_year = lastYear)
}else{
  p <- prepare_data(s,
                    min_n_routes = 1,
                    min_max_route_years = 3,
                    min_year = firstYear,
                    max_year = lastYear)
}

ps <- prepare_spatial(p,
                      strata_map = load_map(stratification),
                      label_size = 1)

print(ps$spatial_data$map)

pm <- prepare_model(ps,
                    model = model,
                    model_variant = model_variant,
                    model_file = alternate_model_file)

fit <- run_model(pm,
                 refresh = 200,
                 iter_warmup = 1500,
                 iter_sampling = 2000,
                 max_treedepth = 14, #
                 adapt_delta = 0.8,#initial try with defaults
                 output_dir = "output",
                 output_basename = paste(species,stratification,model,model_variant,sep = "_"))
#bbsBayes2 saves full cmdstanr fit object in 
# rds file stored as
# saveRDS(fit,paste0(output_dir,output_basename,".rds))


# this is a wrapper around stanfit$summary()
summ <- get_summary(fit) #full parameter summary including convergence diagnostics
saveRDS(summ,file = paste0("output/",paste(species,stratification,model,model_variant,sep = "_"),"param_summ.rds"))

if(max(summ$rhat,na.rm = TRUE) > 1.05){
  stop(paste("Rhat is too high", max(summ$rhat,na.rm = TRUE)))
}

}



# Accessing the saved cmdstanr fit object ---------------------------------


for(species in sps_to_run){
  #bbsBayes2 saves full cmdstanr fit object in 
  # rds file
  
  bbsBayes2_fit <- readRDS(paste0("output/",
                                  paste(species,stratification,model,model_variant,sep = "_"),
                                  ".rds"))

  
  inds <- generate_indices(bbsBayes2_fit,
                           alternate_n = "n")
  
  trends <- generate_trends(inds)
  
  map <- plot_map(trends)
  
  print(map)
  
  # # this is the CmdStanMCMC fit object
  # stanfit <- bbsBayes2_fit$model_fit
  # 
  # # the rest of the bbsBayes2_fit object is the data
  # # spatial information, etc.
  # 
  
  ## cmdstanr$summary() object
  summ <- readRDS(file = paste0("output/",paste(species,stratification,model,model_variant,sep = "_"),"param_summ.rds"))
  
  print(max(summ$rhat,na.rm = TRUE))
}






