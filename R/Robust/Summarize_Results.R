library(ggplot2)
library(dplyr)
library(tidyr)
library(inline)

wc.code <- "
uintmax_t linect = 0; 
uintmax_t tlinect = 0;

int fd, len;
u_char *p;

struct statfs fsb;

static off_t buf_size = SMALL_BUF_SIZE;
static u_char small_buf[SMALL_BUF_SIZE];
static u_char *buf = small_buf;

PROTECT(f = AS_CHARACTER(f));

if ((fd = open(CHAR(STRING_ELT(f, 0)), O_RDONLY, 0)) >= 0) {

if (fstatfs(fd, &fsb)) {
fsb.f_iosize = SMALL_BUF_SIZE;
}

if (fsb.f_iosize != buf_size) {
if (buf != small_buf) {
free(buf);
}
if (fsb.f_iosize == SMALL_BUF_SIZE || !(buf = malloc(fsb.f_iosize))) {
buf = small_buf;
buf_size = SMALL_BUF_SIZE;
} else {
buf_size = fsb.f_iosize;
}
}

while ((len = read(fd, buf, buf_size))) {

if (len == -1) {
(void)close(fd);
break;
}

for (p = buf; len--; ++p)
if (*p == '\\n')
++linect;
}

tlinect += linect;

(void)close(fd);

}
SEXP result;
PROTECT(result = NEW_INTEGER(1));
INTEGER(result)[0] = tlinect;
UNPROTECT(2);
return(result);
";

setCMethod("wc",
           signature(f="character"), 
           wc.code,
           includes=c("#include <stdlib.h>", 
                      "#include <stdio.h>",
                      "#include <sys/param.h>",
                      "#include <sys/mount.h>",
                      "#include <sys/stat.h>",
                      "#include <ctype.h>",
                      "#include <err.h>",
                      "#include <errno.h>",
                      "#include <fcntl.h>",
                      "#include <locale.h>",
                      "#include <stdint.h>",
                      "#include <string.h>",
                      "#include <unistd.h>",
                      "#include <wchar.h>",
                      "#include <wctype.h>",
                      "#define SMALL_BUF_SIZE (1024 * 8)"),
           language="C",
           convention=".Call")

setwd("~/Desktop/Results/Robust/")

P_range = c(4, 6, 8, 10)
T_range = c(4, 6, 8, 10)
Num_scenarios = 20
Sigma_range = c(0.1, 0.5, 1.0, 2.0)
Gamma_range = c(0.8, 0.85, 0.9, 0.95)
Lambda_range = c(0.1, 0.5, 1.0, 2.0)

nrows = length(P_range)*length(T_range)*Num_scenarios*length(Sigma_range)*length(Gamma_range)*length(Lambda_range)

File_lengths = numeric(nrows)

count = 1
for (P in P_range){
  for (T in T_range){
    for (Scenario_num in 1:Num_scenarios){
      for (Sigma in Sigma_range){
        for (Gamma in Gamma_range){
          for (Lambda in Lambda_range){
            
            Sigma  = format(Sigma,  nsmall=1)
            Gamma  = format(Gamma,  nsmall=1)
            Lambda = format(Lambda, nsmall=1)
            
            Read_path=paste("Results_Summaries/",
                            toString(P), "_", 
                            toString(T), "_", 
                            toString(Scenario_num), "_",
                            toString(Sigma), "_",
                            toString(Gamma), "_", 
                            toString(Lambda), ".csv", sep="")
            
            File_lengths[count] = wc(Read_path) - 1
            count = count + 1
          }
        }
      }
    }
  }
}

Num_rows = sum(File_lengths)
Cum_num_rows = c(0, cumsum(File_lengths))

Summary = data.frame(P                  = integer(Num_rows),
                     T                  = integer(Num_rows),
                     Scenario_num       = integer(Num_rows),
                     Sigma              = double(Num_rows),
                     Gamma              = double(Num_rows),
                     Lambda             = double(Num_rows),
                     Sim_num            = integer(Num_rows),
                     Theta              = double(Num_rows),
                     Phi                = double(Num_rows),
                     Test_P             = integer(Num_rows),
                     MIO_Time           = integer(Num_rows),
                     Rho                = double(Num_rows),
                     Accuracy           = double(Num_rows),
                     Delta              = double(Num_rows),
                     Objective          = double(Num_rows),
                     Solution_Type      = factor(Num_rows),
                     Scenario_Type      = factor(Num_rows))

file_list <- list.files("C:/foo/")
dataset <- do.call("rbind",lapply(file_list, FUN=function(files){read.csv(files,header=TRUE)}))

count = 1
for (P in P_range){
  for (T in T_range){
    for (Scenario_num in 1:Num_scenarios){
      for (Sigma in Sigma_range){
        for (Gamma in Gamma_range){
          for (Lambda in Lambda_range){
            
            Sigma  = format(Sigma,  nsmall=1)
            Gamma  = format(Gamma,  nsmall=1)
            Lambda = format(Lambda, nsmall=1)
            
            Read_path=paste("Results_Summaries/",
                            toString(P), "_", 
                            toString(T), "_", 
                            toString(Scenario_num), "_",
                            toString(Sigma), "_",
                            toString(Gamma), "_", 
                            toString(Lambda), ".csv", sep="")
            
            Raw_data = read.csv(Read_path, header = TRUE)
            
            Summary[(Cum_num_rows[count]+1):Cum_num_rows[count+1],] = Raw_data

            print(count)
            count = count + 1
          }
        }
      }
    }
  }
}

write.csv(file="Files/Summary.csv", Summary, row.names = FALSE)