# R notebook source
# -------------------------------------------------------------------------
# Copyright (c) 2022 Craig Robert Shenton. All rights reserved.
# Licensed under the MIT License. See license.txt in the project root for
# license information.
# -------------------------------------------------------------------------

# FILE:           cqc-icb-lookup.R
# DESCRIPTION:    
# CONTRIBUTORS:   Craig R. Shenton
# CONTACT:        craig.shenton@nhs.net
# CREATED:        09 Nov 2022
# VERSION:        0.0.1


# Load libs and global vars
# -------------------------------------------------------------------------

# load dataframe packages
library(here)
library(tidyverse)
library(tidyr)
library(dplyr)
library(readxl)
library(RCurl)

# Download CQC Codes dataset
# -------------------------------------------------------------------------
# url <- "https://www.cqc.org.uk/about-us/transparency/using-cqc-data"
# Section: Care directory with filters
# File: Care directory with filters (01 November 2022) (ods, 23.03MB, English)
# Open and save second sheet as .csv file

# Download ICB Codes dataset
# url <- "https://geoportal.statistics.gov.uk/documents/locations-to-integrated-care-boards-to-nhs-england-region-july-2022-lookup-in-england/about"
# Section: Locations to Integrated Care Boards to NHS England (Region) (July 2022) Lookup in England
# File: LOC22_ICB22_NHSER22_EN_LU.xlsx

# Read data from table
# -------------------------------------------------------------------------
file_path <- here("data", "01_November_2022_HSCA_Active_Locations.csv")
df_cqc <- read.csv(file_path, header = TRUE, sep = ",") %>%
  filter(`Dormant..Y.N.` == 'N' & `Care.home.` == 'Y')

file_path <- here("data", "LOC22_ICB22_NHSER22_EN_LU.xlsx")
df_ons <- read_excel(file_path, sheet = "LOC22_ICB22_NHSER22_EN_LU", skip=0) %>%
  rename(c('Location.ONSPD.CCG.Code' = `LOC22CD`))

df_codes <- df_cqc %>%
  inner_join(df_ons, by="Location.ONSPD.CCG.Code") %>%
  # move age to first column
  dplyr::select("Location.ID",
                "Location.HSCA.start.date",
                "Dormant..Y.N.",
                "Care.home.",
                "Location.Name",
                "Location.ODS.Code",
                "Location.Telephone.Number",
                "Location.Web.Address",
                "Care.homes.beds",
                "Location.Type.Sector",
                "Location.Inspection.Directorate",
                "Location.Primary.Inspection.Category",
                "Location.Latest.Overall.Rating",
                "Publication.Date",
                "Inherited.Rating..Y.N.",
                "Location.Region",
                "Location.NHS.Region",
                "Location.Local.Authority",
                "Location.ONSPD.CCG.Code",
                "Location.ONSPD.CCG",
                "LOC22CDH",
                "LOC22NM",
                "ICB22CD",
                "ICB22CDH",
                "ICB22NM",
                "NHSER22CD",
                "NHSER22CDH",
                "NHSER22NM", 
                everything())

# Write joined data to .csv
# -------------------------------------------------------------------------
writePath <- here("data", "cqc-icb-lookup.csv")
write.csv(df_codes, writePath, row.names = FALSE)

# Example Queries
# -------------------------------------------------------------------------

## 1. All Care Homes in ICB
df_suffolk_icb <- df_codes %>%
  filter(`ICB22NM` == 'NHS Suffolk and North East Essex Integrated Care Board')

## 2. All Care Homes in sub-ICB
df_suffolk_subicb <- df_codes %>%
  filter(`LOC22NM` == 'NHS Suffolk and North East Essex ICB - 06L')

## 3. All Care Homes that are a Domiciliary service
df_domiciliary <- df_codes %>%
  filter(`Service.type...Domiciliary.care.service` == 'Y')

## 4. local authorities mapped to NHS sub-ICBs
df_la <- df_codes %>%
  dplyr::select("Location.Region",
                "Location.NHS.Region",
                "Location.Local.Authority",
                "Location.ONSPD.CCG.Code",
                "Location.ONSPD.CCG",
                "LOC22CDH",
                "LOC22NM",
                "ICB22CD",
                "ICB22CDH",
                "ICB22NM",
                "NHSER22CD",
                "NHSER22CDH",
                "NHSER22NM")
df_subicb_to_la <- df_la[!duplicated(df_la[ , c("Location.Local.Authority", "LOC22NM")]), ]

writePath <- here("data", "subicb-la-lookup.csv")
write.csv(df_subicb_to_la, writePath, row.names = FALSE)

## 5. local authorities mapped to NHS ICBs
df_la2 <- df_codes %>%
  dplyr::select("Location.Region",
                "Location.NHS.Region",
                "Location.Local.Authority",
                "ICB22CD",
                "ICB22CDH",
                "ICB22NM",
                "NHSER22CD",
                "NHSER22CDH",
                "NHSER22NM")
df_icb_to_la <- df_la2[!duplicated(df_la2[ , c("Location.Local.Authority", "ICB22NM")]), ]

writePath <- here("data", "icb-la-lookup.csv")
write.csv(df_icb_to_la, writePath, row.names = FALSE)

