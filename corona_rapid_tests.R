library(tidyverse)
library(cowplot)
library(scales)
library(here)

rkiGrey <- "#638399"
rkiLightGrey <- "#D8E0E6"
rkiBlue <- "#005EB8"

rkiThemeP1 <- function() {
  theme_half_open(font_size = 12,
                  line_size = .5,
                  rel_tiny = .7) %+replace%
    theme(
      title = element_text(color = rkiBlue),
      axis.line = element_line(color = rkiLightGrey),
      axis.text =  element_text(color = rkiBlue,size = 10),
      axis.ticks = element_line(color = rkiLightGrey)
    )
  
}
rkiThemeP1Inv <- function() {
  theme_half_open(font_size = 12,
                  line_size = .5,
                  rel_tiny = .7) %+replace%
    theme(
      title = element_text(color = rkiBlue),
      axis.line = element_line(color = rkiBlue),
      axis.text =  element_text(color = rkiBlue,size = 10),
      axis.ticks = element_line(color = rkiBlue)
    )
  
}


plot_quality <- function(sens,spec,limitX = 1){
  prevalence <- seq (0, 1, .0001)
  sensitivity <- sens
  specificity <- spec
  
  PPV = (sensitivity * prevalence) / ((sensitivity * prevalence) + ((1 - specificity) * (1 - prevalence)))
  df <- tibble(prevalence, PPV)
  
  captionString <- paste0(format(sensitivity*10000,big.mark = ","), " von 10,000 infizierten Personen werden korrekt als infiziert erkannt (Sensitivität = ",sensitivity,") & \n ",
                          format(specificity*10000,big.mark = ",")," von 10,000 nicht infizierten Personen werden korrekt als nicht infiziert erkannt (Spezifizität = ",specificity,")")
  # rapid test full
  ggplot(df) + geom_line(aes(prevalence, PPV), size = 1, color = rkiGrey) +
    scale_x_continuous(labels= seq(0,limitX*100,10),breaks = round(seq(0, limitX, .1), 1),limits = c(0, limitX)) +
    scale_y_continuous(labels = percent, limits = c(0, 1)) +
    annotate("text", prevalence[6] + .165*limitX,PPV[6], label = "Ungezieltes Testen", color = rkiGrey) +
    annotate("text", prevalence[1001] + .15*limitX, PPV[1001] - .025, label = "Gezieltes Testen", color = rkiGrey) +
    geom_point(aes(x = prevalence[6], y = PPV[6]), size = 2, color = rkiGrey) +
    geom_point(aes(x = prevalence[1001], y = PPV[1001]), size = 2, color = rkiGrey) +
    labs(x = "Anzahl infizierter Personen von 100 Getesteten",
         y = "Wahrscheinlichkeit bei positivem Testergebnis\ntatsächlich infiziert zu sein",
         caption = captionString) +
    rkiThemeP1()

}

plot_quality(.8,.98,1)
ggsave(filename = paste("test","sens",.8,"spec",.98,"limit",1,".pdf",sep="_"), width = 140, height = 106, units = "mm")
plot_quality(.8,.98,.3)
ggsave(filename = paste("test","sens",.8,"spec",.98,"limit",.3,".pdf",sep="_"), width = 140, height = 106, units = "mm")
plot_quality(.8,.999,1)
ggsave(filename = paste("test","sens",.8,"spec",.999,"limit",1,".pdf",sep="_"), width = 140, height = 106, units = "mm")
plot_quality(.8,.999,.3)
ggsave(filename = paste("test","sens",.8,"spec",.999,"limit",.3,".pdf",sep="_"), width = 140, height = 106, units = "mm")


# transmission events
xaxis <- seq(0, 30, .01)
yaxis <- (exp(1) ^ (-xaxis / 5))
df <- tibble(xaxis, yaxis)
ggplot(df, aes(xaxis, yaxis)) +
  geom_area(fill = rkiGrey) +
  scale_x_continuous(breaks = NULL, expand = c(0, 0)) +
  scale_y_continuous(breaks = NULL, expand = c(0, 0)) +
  geom_segment(aes(x = 0, xend = 30, y = 0, yend = 0), lineend = "round", linejoin = "round", arrow = arrow(type = "closed",  length = unit(2, "mm")),color=rkiBlue) +
  geom_segment(aes(x = 0, xend = 0, y = 0, yend = 1.1), lineend = "round", linejoin = "round", arrow = arrow(type = "closed",  length = unit(2, "mm")),color=rkiBlue) +
  coord_cartesian(clip = 'off')+   labs(x = "Anteil der Übertragungereignisse", y = "") +
  rkiThemeP1Inv()

ggsave(filename = "transmission_events.pdf", width = 214, height = 74, units = "mm" )
