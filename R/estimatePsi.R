estimatePsi  <-  function(#Computes the Targeted Minimum Loss Estimator of Psi.
### Computes  the targeted  minimum loss  estimator of  Psi and  estimates its
### standard deviation.
                          obs,  ### A  \code{data.frame}  of observations,  as
### produced by \code{getSample}.
                          what,     ###     A  \code{character} indicating the
### parameter of  interest to  estimate.  Either  "ATE" for  Average Treatment
### Effect,  the  difference  between  the  means  under  '\eqn{do(A=1)}'  and
### '\eqn{do(A=0)}', or  "MOR" for the  Mean under the Optimal  treatment Rule
### '\eqn{do(A=r(W))}'.
                          Qtab=NULL, ### A \code{matrix} of  conditional means of \eqn{Y} given  \eqn{(A,W)} at the
### observations as they are currently estimated. 
                          QEpstab, ### A  \code{matrix} of  estimated conditional  expectations of  \eqn{Y} given
### \eqn{(A,W)} with columns \code{c("A", "A=0", "A=1")}.
                          epsHtab, ### A  \code{matrix} of  clever  covariates with  columns \code{c("A",  "A=0",
### "A=1")}.
                          ..., ### Additional parameters.
                          verbose=FALSE ### A \code{logical}  or an \code{integer}  indicating the level  of verbosity
### (defaults to 'FALSE').
                          ) {
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Validate arguments
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  ## Argument 'obs'
  obs <- validateArgumentObs(obs)
  Y <- obs[, "Y"]

  ## Arguments 'what'
  if (!(what %in% c("ATE", "MOR"))) {
    throw("Argument 'what' must be either 'ATE' or 'MOR', not: ", what)
  }

  ## Argument 'Qtab', only used if 'what' equals 'MOR'
  if (what=="MOR") {
    Qtab <- Arguments$getNumerics(Qtab)
    test <- !is.matrix(Qtab) ||
        !identical(colnames(Qtab), c("A", "A=0", "A=1")) ||
            !(nrow(obs)==nrow(Qtab))
    if (test) {
      throw("Argument 'Qtab' does not meet the constraints.")
    }
  }
  
  ## Argument 'QEpstab'
  QEpstab <- Arguments$getNumerics(QEpstab)
  test <- !is.matrix(QEpstab) ||
      !identical(colnames(QEpstab), c("A", "A=0", "A=1")) ||
          !(nrow(obs)==nrow(QEpstab))
  if (test) {
    throw("Argument 'QEpstab' does not meet the constraints.")
  }

  ## Argument 'epsHtab'
  epsHtab <- Arguments$getNumerics(epsHtab)
  test <- !is.matrix(epsHtab) ||
      !identical(colnames(epsHtab), c("A", "A=0", "A=1")) ||
          !(nrow(obs)==nrow(epsHtab))
  if (test) {
    throw("Argument 'epsHtab' does not meet the constraints.")
  }
  
  
  ## Argument 'verbose'
  verbose <- Arguments$getVerbose(verbose)

  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Core
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (what=="ATE") {
    psi <- mean(QEpstab[, "A=1"]-QEpstab[, "A=0"])
    psi.sd <- sqrt(mean(
        (epsHtab[, "A"]*(Y-QEpstab[, "A"]) +
         QEpstab[, "A=1"]-QEpstab[, "A=0"] - psi)^2))
  } else if (what=="MOR") {
    A <- obs[, "A"]
    rA <- as.numeric((Qtab[, "A=1"]-Qtab[, "A=0"])>0)
    rAequalsA <- (rA==A)
    col <- match(c("A=0", "A=1"), colnames(QEpstab))
    rA <- col[rA+1]
    psi <- mean(QEpstab[cbind(1:nrow(QEpstab), rA)])
    psi.sd <- sqrt(mean(
        (epsHtab[, "A"]*(Y-QEpstab[, "A"])*rAequalsA +
         QEpstab[cbind(1:nrow(QEpstab), rA)] - psi)^2))
  }
  out <- c(psi=psi, psi.sd=psi.sd)
  return(out)
### Returns a \code{vector} giving the  estimates of the targeted minimum loss
### and its standard deviation.
}



############################################################################
## HISTORY:
## 2016-09-16
## o Created.
############################################################################

