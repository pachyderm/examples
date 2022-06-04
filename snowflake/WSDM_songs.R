
# packages ----------------------------------------------------------------

if (!require('readxl')) install.packages('readxl')
if (!require('dplyr')) install.packages('dplyr')
if (!require('ggplot2')) install.packages('ggplot2')
if (!require('lubridate')) install.packages('lubridate')
if (!require('scales')) install.packages('scales')
if (!require('tidyr')) install.packages('tidyr')
if (!require('data.table')) install.packages('data.table')
if (!require('tibble')) install.packages('tibble')
if (!require('scattermore')) install.packages('scattermore', repos = "https://github.com/exaexa/scattermore")


library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)
library(tidyr)
library(data.table)
library(tibble)
library(scattermore)

# data --------------------------------------------------------------------

# members <- as_tibble(fread('members_v3.csv', nrows = 1e6))
# trans <- as_tibble(fread('transactions_v2.csv', nrows = 1e6))
# logs <- as_tibble(fread('user_logs_v2.csv', nrows = 1e6))
members <- as_tibble(fread('/pfs/MEMBERSHIPS/0000', nrows = 1e6))
names(members) <- c("msno","city","bd","gender","registered_via","registration_init_time")

trans <- as_tibble(fread('/pfs/TRANSACTIONS/0000', nrows = 1e6))
names(trans) <- c("msno","payment_method_id","payment_plan_days","plan_list_price","actual_amount_paid","is_auto_renew", "transaction_date","membership_expire_date","is_cancel")

logs <- as_tibble(fread('/pfs/USER_LOGS/0000', nrows = 1e6, colClasses=))
names(logs) <- c("msno","date","num_25","num_50","num_75","num_985", "num_100","num_unq","total_secs")

# data wrangling
trans2 <- trans %>% 
  mutate(transaction_date = ymd(transaction_date),
         membership_expire_date = ymd(membership_expire_date))
  
members2 <- members %>% 
  mutate(registration_init_time = ymd(registration_init_time))

logs2 <- logs %>% 
  mutate(date = ymd(date))

logs2_mean <- logs2 %>% 
  summarise(median = median(total_secs, na.rm = TRUE),
            mean = mean(total_secs, na.rm = TRUE))

# plot --------------------------------------------------------------------

pdf(NULL)

###transactions

#trans weekday
a <- trans2 %>% 
  #filter out final days with outliers
  filter(transaction_date < as.Date("2017-01-01")) %>% 
  mutate(weekday = lubridate:: wday(transaction_date, label = TRUE, abbr = FALSE)) %>%
  group_by(weekday) %>% 
  count() %>% 
  ggplot(aes(x = weekday, y = n))+
  geom_col(fill = "#008b45", width = 0.7)+
  scale_y_continuous(labels = scales::label_number(scale_cut = cut_short_scale()),
                     expand = expansion(mult = c(0,0.05)))+
  labs(
    title = "Transactions by day of week",
    x = "",
    y = "Transactions"
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.y = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )


ggsave(plot = a, "/pfs/out/trans_weekday.png", width = 8, height = 5)


#cancel
b <- trans2 %>% 
  count(is_cancel) %>% 
  ggplot(aes(x = n, y = reorder(is_cancel, n), fill = as.factor(is_cancel)))+
  geom_col(show.legend = FALSE)+
  geom_text(aes(label = n), hjust = 0, nudge_x = 10000,
            fontface = "bold")+
  labs(
    title = "Did the user canceled the membership?",
    x = "Transactions",
    y = ""
  )+
  scale_y_discrete(labels = c("Yes", "No"))+
  scale_x_continuous(labels = scales::label_number(scale_cut = cut_short_scale()),
                     expand = expansion(mult = c(0,0.15)))+
  scale_fill_manual(
    values = c(
      "#3b4992",
      "#ee2200"
    )
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.x = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )

ggsave(plot = b, "/pfs/out/trans_cancel.png", width = 8, height = 5)

#renew

c <- trans2 %>% 
  count(is_auto_renew) %>% 
  ggplot(aes(x = n, y = reorder(is_auto_renew, n), fill = as.factor(is_auto_renew)))+
  geom_col(show.legend = FALSE)+
  geom_text(aes(label = n), hjust = 0, nudge_x = 10000,
            fontface = "bold")+
  labs(
    title = "Automatic renewal option on each transaction",
    x = "Transactions",
    y = ""
  )+
  scale_y_discrete(labels = c("Disabled", "Enabled"))+
  scale_x_continuous(labels = scales::label_number(scale_cut = cut_short_scale()),
                     expand = expansion(mult = c(0,0.15)))+
  scale_fill_manual(
    values = c(
      "#631779",
      "#008280"
    )
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.x = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )

ggsave(plot = c, "/pfs/out/trans_renew.png", width = 8, height = 5)

### members

#gender
d <- members2 %>% 
  count(gender) %>% 
  ggplot(aes(x = n, y = reorder(gender,n), fill = gender))+
  geom_col(show.legend = FALSE)+
  scale_y_discrete(labels = c("Female", "Male", "NA"))+
  scale_x_continuous(labels = scales::label_number(scale_cut = cut_short_scale()),
                     expand = expansion(mult = c(0,0.05)))+
  scale_fill_manual(
    values = c(
      "#ee2200",
      "#631779",
      "#008b45"
    )
  )+
  labs(
    title = "Gender of users",
    x = "Users",
    y = ""
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.x = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )


ggsave(plot = d, "/pfs/out/members_gender.png", width = 8, height = 5)

#users registered by day
e <- members2 %>% 
  group_by(registration_init_time) %>% 
  count() %>% 
  ggplot(aes(x = registration_init_time, y = n))+
  geom_line(color = "#631779")+
  scale_x_date(date_breaks = "year", date_labels = "%Y")+
  scale_y_continuous(breaks = seq(0,3000,500))+
  labs(
    title = "Number of users registered by day",
    x = "Date",
    y = "Users registered"
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.y = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )


ggsave(plot = e, "/pfs/out/members_registered_date.png", width = 8, height = 5)

#users registered by weekday
f <- members2 %>% 
  mutate(weekday = lubridate:: wday(registration_init_time, label = TRUE, abbr = FALSE)) %>%
  group_by(weekday) %>% 
  count() %>% 
  ggplot(aes(x = weekday, y = n))+
  geom_col(fill = "#631779", width = 0.7)+
  scale_y_continuous(labels = scales::label_number(scale_cut = cut_short_scale()),
                     expand = expansion(mult = c(0,0.05)))+
  labs(
    title = "Users registered by day of week",
    x = "",
    y = "Users"
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.y = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )


ggsave(plot = f, "/pfs/out/members_registered_weekday.png", width = 8, height = 5)

### logs

#density hours per day

g <- logs2 %>% 
  filter(total_secs < 86400) %>% 
  ggplot(aes(x = total_secs))+
  geom_density(fill = "#008b45")+
  scale_x_continuous(breaks = seq(0,86400, 3600),
                     labels = seq(0,24,1),
                     expand = c(0,0))+
  scale_y_continuous(expand = expansion(mult = c(0,0.05)))+
  labs(
    title = "Hours of songs listened on day",
    x = "Hours",
    y = "Density"
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.y = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )+
  coord_cartesian(xlim = c(0,86400))


ggsave(plot = g, "/pfs/out/logs_density_hours_day.png", width = 8, height = 5)


#density minutes per day

h <- logs2 %>% 
  filter(total_secs < 86400) %>% 
  ggplot(aes(x = total_secs))+
  geom_density(fill = "#008b45")+
  geom_vline(data = logs2_mean, aes(xintercept = mean),
             color = "#008280")+
  annotate(geom = "text", x = 7700, y = 0.0001,
           label = "Mean", angle = 90,
           fontface = "bold", color = "#008280")+
  geom_vline(data = logs2_mean, aes(xintercept = median),
             color = "#631779")+
  annotate(geom = "text", x = 4400, y = 0.0001,
           label = "Median", angle = 90,
           fontface = "bold", color = "#631779")+
  scale_x_continuous(breaks = seq(0,86400, 1800),
                     labels = seq(0,1440,30),
                     expand = c(0,0))+
  scale_y_continuous(expand = expansion(mult = c(0,0.05)))+
  labs(
    title = "Minutes of songs listened on a day (0-160 min)",
    x = "Minutes",
    y = "Density"
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.y = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )+
  coord_cartesian(xlim = c(0,9600))


ggsave(plot = h, "/pfs/out/logs_density_minutes_day.png", width = 8, height = 5)

# logs per day

i <- logs2 %>% 
  group_by(date) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(mean_n_logs = mean(n)) %>% 
  ggplot(aes(x = date, y = n))+
  geom_hline(aes(yintercept = mean_n_logs),
             color = "#01a087")+
  annotate("text", x = as.Date("2017-03-20"), y = 32200,
           label = "Mean", color = "#01a087", fontface = "bold")+
  geom_line(color = "#ee2200", size = 1)+
  geom_point(color = "#ee2200", fill = "white",
             shape = 21, stroke = 1)+
  scale_x_date()+
  scale_y_continuous(labels = scales::label_number(scale_cut = cut_short_scale()))+
  labs(
    title = "Number of people logs by day",
    x = "Date",
    y = "Logs"
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.y = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )
  

ggsave(plot = i, "/pfs/out/logs_logs_day.png", width = 8, height = 5)


# logs per day of week

j <- logs2 %>% 
  mutate(weekday = lubridate:: wday(date, label = TRUE, abbr = FALSE)) %>%
  group_by(weekday) %>% 
  count() %>% 
  ggplot(aes(x = weekday, y = n))+
  geom_col(fill = "#ee2200", width = 0.7)+
  scale_y_continuous(labels = scales::label_number(scale_cut = cut_short_scale()),
                     expand = expansion(mult = c(0,0.05)))+
  labs(
    title = "Number of people logs by day of week",
    x = "",
    y = "Logs"
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.y = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )


ggsave(plot = j, "/pfs/out/logs_logs_weekday.png", width = 8, height = 5)

# songs per day

k <- logs2 %>% 
  group_by(date) %>% 
  summarise(n_songs = sum(num_unq)) %>% 
  ungroup() %>% 
  mutate(mean_n_songs = mean(n_songs)) %>% 
  ggplot(aes(x = date, y = n_songs))+
  geom_hline(aes(yintercept = mean_n_songs),
             color = "#01a087")+
  annotate("text", x = as.Date("2017-03-21"), y = 934000,
           label = "Mean", color = "#01a087", fontface = "bold")+
  geom_line(color = "#3c5488", size = 1)+
  geom_point(color = "#3c5488", fill = "white",
             shape = 21, stroke = 1)+
  scale_x_date()+
  scale_y_continuous(labels = scales::label_number(scale_cut = cut_short_scale()))+
  labs(
    title = "Number of songs listened by day",
    x = "Date",
    y = "Songs listened"
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.y = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )
  

ggsave(plot = k, "/pfs/out/logs_songs_day.png", width = 8, height = 5)


# songs per day of week

l <- logs2 %>% 
  mutate(weekday = lubridate:: wday(date, label = TRUE, abbr = FALSE)) %>%
  group_by(weekday) %>%  
  summarise(n_songs = sum(num_unq)) %>% 
  ggplot(aes(x = weekday, y = n_songs))+
  geom_col(fill = "#3c5488", width = 0.7)+
  scale_y_continuous(labels = scales::label_number(scale_cut = cut_short_scale()),
                     expand = expansion(mult = c(0,0.05)))+
  labs(
    title = "Number of songs listened by day of week",
    x = "",
    y = "Songs listened"
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.y = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )


ggsave(plot = l, "/pfs/out/logs_songs_weekday.png", width = 8, height = 5)


#scatter
m <- logs2 %>% 
  ggplot(aes(x = num_unq, y = total_secs))+
  scattermore::geom_scattermore()+
  geom_smooth(method = "lm",
              color = "#3b4992")+
  scale_y_continuous(labels = scales::label_number(scale_cut = cut_short_scale()),
                     expand = expansion(mult = c(0,0.05)))+
  scale_x_continuous(expand = expansion(mult = c(0,0.05)))+
  labs(
    title = "Number of songs listened x Total seconds listened",
    x = "Songs",
    y = "Seconds"
  )+
  theme_classic()+
  theme(
    plot.background = element_rect(fill = "#f0f0f0"),
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    panel.background = element_rect(fill = "#f0f0f0"),
    panel.grid.major.y = element_line(color = "#c9c9c9",linetype = "dashed"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold")
  )+
  coord_cartesian(ylim = c(0,200000))

ggsave(plot = m, "/pfs/out/logs_scatter.png", width = 8, height = 8)
