
# A function is reusable code that takes inputs and returns outputs.
categorise_time <- function(time_in_seconds)
{
  # Validate input: if missing, return NA (not available).
  if (is.na(time_in_seconds))
    return(NA)
  
  # Use thresholds to return a category label.
  if (time_in_seconds < 180)
    return("fast")
  else if (time_in_seconds < 360)
    return("moderate")
  else
    return("slow")
}