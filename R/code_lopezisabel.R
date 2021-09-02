
getwd()

#Install and load packages
install.packages("tidycensus")
install.packages("dplyr",dependencies= TRUE)
library(tidycensus)
library(tidyverse)
library(lubridate)
library(sf)
library(viridis)
library(ggthemes)
library(dplyr)
library(here)
census_api_key("7588f82efc1da358e08fa5ab1e4ad21fce8519c3", install = TRUE)

readRenviron("~/.Renviron")
Sys.getenv("7588f82efc1da358e08fa5ab1e4ad21fce8519c3")

#Defining constants for downloads

base_URL <- "https://data.bls.gov/cew/data/files/"

sic_subdirs <- "/sic/csv/"
sic_prefix <- "sic_"
sic_body <- "_annual_by_area"
sic_extension <- ".zip"

naic_subdirs <- "/csv/"
naic_prefix <-  ""
naic_body <- "_annual_by_area"
naic_extension <- ".zip"

#Defining FIPS Codes to be considered for analysis- Shoreline Counties

shoreline_counties <- county= c('Baldwin','Mobile', 'Aleutians East Borough','Aleutians West Census Area',
                                'Anchorage Municipality', 'Bethel Census Area', 'Bristol Bay Borough', 'Dillingham Census Area',
                                'Haine Borough', 'Hoonah-Angoon Census Area', 'Juneau City and Borough', 'Kenia Peninsula Borough',
                                'Ketchikan Gateway Borough', 'Kodiak Island Borough', 'Lake and Peninsula Borough', 'Matannuska-Susitna Borough',
                                'Nome Census Area', 'North Slope Borough', 'Northwest Artic Borough', 'Petersburg Census Area',
                                'Prince of Wales-Hyder Census Area', 'Sitka City and Borough', 'Skagway Municipality', 'Valdez-Cordova Census Area',
                                'Wade Hampton Census Area', 'Wrangell City and Borough', 'Yakutat City and Borough', 'Alameda', 'Contra Costa', 'Del Norte', 
                                'Humboldt', 'Los Angeles', 'Marin', 'Mendocino', 'Monterey', 'Napa', 'Orange', 'San Diego', 'San Francisco', 'San Luis Obispo',
                                'San Mateo', 'Santa Barbara', 'Santa Clara', 'Santa Cruz', 'Solano', 'Sonoma', 'Ventura', 'Fairfield', 'Middlesex', 'New Haven', 
                                'New London', 'Kent', 'New Castle', 'Sussex', 'District of Columbia', 'Bay', 'Brevard', 'Broward', 'Charlotte', 'Citrus', 'Clay',
                                'Collier', 'Dixie', 'Duval', 'Escambia', 'Flagler', 'Franklin', 'Gulf', 'Hernando', 'Hillsborough', 'Indian River', 'Jefferson', 
                                'Lee', 'Levy', 'Liberty', 'Manatee', 'Martin', 'Miami-Dade', 'Monroe', 'Nassau', 'Okaloosa', 'Palm Beach', 'Pasco', 'Pinellas', 
                                'Putnam', 'St. Johns', 'St. Lucie', 'Santa Rosa', 'Sarasota', 'Taylor', 'Volusia', 'Wakulla', 'Walton', 'Brantley', 'Bryan', 
                                'Camden', 'Charlton', 'Chatham', 'Glynn', 'Liberty', 'McIntosh', 'Wayne', 'Hawaii', 'Honolulu', 'Kalawao', 'Kauai', 'Maui',
                                'Cook', 'Lake', 'Lake', 'LaPorte', 'Porter', 'Ascension Parish', 'Assumption Parish', 'Calcasieu', 'Cameron', 'Iberia', 'Jefferson',
                                'Jefferson Davis Parish', 'Lafourche Parish', 'Livingston Parish', 'Orleans Parish', 'Plaquemines Parish', 'St. Bernard Parish',
                                'St. Charles Parish', 'St. James Parish', 'St. John the Baptist Parish', 'St. Martin Parish', 'St. Mary Parish', 'St. Tammany Parish',
                                'Tangipahoa Parish', 'Terrebonne Parish', 'Vermilion Parish', 'Cumberland Parish', 'Hancock', 'Knox', 'Lincoln', 'Sagadahoc', 'Waldo',
                                'Washington', 'York', 'Anne Arundel', 'Baltimore', 'Calvert', 'Caroline', 'Cecil', 'Charles', 'Dorchester', 'Harford', 'Howard', 'Kent',
                                'Prince Georges', 'Queen Annes', 'St. Marys', 'Somerset', 'Talbot', 'Wicomico', 'Worcester', 'Baltimore City', 'Barnstable', 'Bristol',
                                'Dukes', 'Essex', 'Middlesex', 'Nantucket', 'Norfolk', 'Plymouth', 'Suffolk', 'Alcona', 'Alger', 'Allegan', 'Alpena', 'Antrim', 'Arenac',
                                'Baraga', 'Bay', 'Benzie', 'Berrien', 'Charlevoix', 'Cheboygan', 'Chippewa', 'Delta', 'Emmet', 'Gogebic', 'Grand Traverse', 'Houghton',
                                'Huron', 'Iosco', 'Keweenaw', 'Leelanau', 'Luce', 'Mackinac', 'Macomb', 'Manistee', 'Marquette', 'Mason', 'Menominee', 'Monroe', 'Muskegon', 
                                'Oceana', 'Ontonagon', 'Ottawa', 'Presque Isle', 'St. Clair', 'Sanilac', 'Schoolcraft', 'Tuscola', 'Van Buren', 'Wayne', 'Cook', 'Lake',
                                'St. Louis', 'Hancock', 'Harrison', 'Jackson', 'Rockingham', 'Strafford', 'Atlantic', 'Bergen', 'Burlington', 'Camden', 'Cape May', 'Cumberland',
                                'Essex', 'Gloucester', 'Hudson', 'Middlesex', 'Monmouth', 'Ocean', 'Salem', 'Somerset', 'Union', 'Bronx', 'Cayuga', 'Chautauqua', 'Dutchess',
                                'Erie', 'Jefferson', 'Kings', 'Monroe', 'Nassau', 'New York', 'Niagara',"Orange",'Orleans', 'Oswego', 'Putnam', 'Queens', 'Richmond', 'Rockland', 
                                'Suffolk', 'Ulster','Wayne', 'Westchester', 'Beaufort', 'Bertie', 'Brunswick', 'Camden', 'Carteret', 'Chowan', 'Craven', 'Currituck', 'Dare', 'Gates',
                                'Hertford', 'Hyde', 'Jones', 'New Hanover', 'Onslow', 'Pamlico', 'Pasquotank', 'Pender', 'Perquimans', 'Pitt', 'Tyrrell', 'Washington', 'Ashtabula',
                                'Cuyahoga', 'Erie', 'Lake', 'Lorain', 'Lucas', 'Ottawa', 'Sandusky', 'Clatsop', 'Coos', 'Curry', 'Douglas', 'Lane', 'Lincoln', 'Tillamook', 'Delaware',
                                'Erie', 'Philadelphia', 'Bristol', 'Kent', 'Newport', 'Providence', 'Washington', 'Beaufort', 'Berkeley', 'Charleston', 'Colleton', 'Dorchester', 'Georgetown',
                                'Hampton', 'Horry', 'Jasper', 'Aransas', 'Brazoria', 'Calhoun', 'Cameron', 'Chambers', 'Galveston', 'Harris', 'Jackson', 'Jefferson', 'Kenedy', 'Kleberg',
                                'Matagorda', 'Nueces', 'Orange', 'Refugio', 'San Patricio', 'Victoria', 'Willacy', 'Accomack', 'Arlington', 'Caroline', 'Charles City', 'Chesterfield', 
                                'Essex', 'Fairfax', 'Gloucester', 'Hanover', 'Henrico', 'Isle of Wight', 'James City', 'King and Queen', 'King George', 'King William', 'Lancaster',
                                'Mathews', 'Middlesex', 'New Kent', 'Northampton', 'Northumberland', 'Prince George', 'Prince William', 'Richmond', 'Spotsylvania', 'Stafford', 'Surry', 
                                'Westmoreland', 'York', 'Alexandria City', 'Chesapeake City', 'Hampton City', 'Hopewell City', 'Newport News City', 'Norfolk City', 'Poquoson City',
                                'Portsmouth City', 'Suffolk City', 'Virginia Beach City', 'Williamsburg City', 'Clallam', 'Grays Harbor', 'Island', 'Jefferson', 'King', 'Kitsap', 'Mason', 
                                'Pacific', 'Pierce', 'San Juan', 'Skagit', 'Snohomish', 'Thurston', 'Wahkiakum', 'Whatcom', 'Ashland', 'Bayfield', 'Brown', 'Door', 'Douglas', 'Iron', 
                                'Kenosha', 'Kewaunee', 'Manitowoc', 'Marinette', 'Milwaukee', 'Oconto', 'Ozaukee', 'Racine', 'Sheboygan', 'Eastern District', 'Manua District', 'Western District',
                                'Guam', 'Northern Islands Municipality', 'Rota Municipality', 'Saipan Municipality', 'Tinian Municipality', 'Aguada Municipio', 'Aguadilla Municipio', 'A?asco Municipio',
                                'Arecibo Municipio', 'Arroyo Municipio', 'Barceloneta Municipio', 'Bayam?n Municipio', 'Cabo Rojo Municipio', 'Camuy Municipio', 'Carolina Municipio', 'Cata?o Municipio',
                                'Ceiba Municipio', 'Culebra Municipio', 'Dorado Municipio', 'Fajardo Municipio', 'Guanica Municipio', 'Guayama Municipio', 'Guayanilla Municipio', 'Guaynabo Municipio', 
                                'Hatillo Municipio', 'Humacao Municipio', 'Isabela Municipio', 'Juana Diaz Municipio', 'Lajas Municipio', 'Loiza Municipio', 'Luquillo Municipio', 'Manati Municipio', 
                                'Maunabo Municipio', 'Mayaguez Municipio', 'Naguabo Municipio', 'Patillas Municipio', 'Pe?uelas Municipio', 'Ponce Municipio', 'Quebradillas Municipio', 'Rincon  
                                Municipio','Rio Grande Municipio', 'Salinas Municipio', 'San Juan Municipio', 'Santa Isabel Municipio', 'Toa Baja Municipio', 'Vega Alta Municipio', 'Vega Baja                               
                                Municipio','Vieques Municipio', 'Yabucoa Municipio', 'Yauco Municipio', 'St. Croix Island', 'St. John Island', 'St. Thomas Island') 

# FIPS Numerical Codes for 452 Counties

fips <- c( '01003','01097','02013','02016','02020','02050','02060','02070','02100','02105','02110','02122','02130',
           '02150','02164','02170','02180','02185','02188','02195','02198','02220','02230','02261','02270' ,'02275',
           '02282','06001','06013','06015','06023','06037','06041','06045','06053','06055','06059','06073', '06075', 
           '06079','06081','06083','06085','06087','06095','06097','06111','09001','09007','09009', '09011', '10001',
           '10003', '10005', '11001', '12005', '12009', '12011', '12015', '12017', '12019', '12021', '12029', '12031',
           '12033', '12035', '12037', '12045', '12053', '12057', '12061', '12065', '12071', '12075', '12077', '12081',
           '12085', '12086', '12087', '12089', '12091', '12099', '12101', '12103', '12107', '12109', '12111', '12113', 
           '12115', '12123', '12127', '12129', '12131', '13025', '13029', '13039', '13049', '13051', '13127', '13179', 
           '13191', '13305', '15001', '15003', '15005', '15007', '15009', '17031', '17097', '18089', '18091', '18127',
           '22005', '22007', '22019', '22023', '22045', '22051', '22053', '22057', '22063', '22071', '22075', '22087',
           '22089', '22093', '22095', '22099', '22101', '22103', '22105', '22109', '22113', '23005', '23009', '23013', 
           '23015', '23023', '23027', '23029', '23031', '24003', '24005', '24009', '24011', '24015', '24017', '24019', 
           '24025', '24027', '24029', '24033', '24035', '24037', '24039', '24041', '24045', '24047', '24510', '25001', 
           '25005', '25007', '25009', '25017', '25019', '25021', '25023', '25025', '26001', '26003', '26005', '26007', 
           '26009', '26011', '26013', '26017', '26019', '26021', '26029', '26031', '26033', '26041', '26047', '26053',
           '26055', '26061', '26063', '26069', '26083', '26089', '26095', '26097', '26099', '26101', '26103', '26105',
           '26109', '26115', '26121', '26127', '26131', '26139', '26141', '26147', '26151', '26153', '26157', '26159',
           '26163', '27031', '27075', '27137', '28045', '28047', '28059', '33015', '33017', '34001', '34003', '34005',
           '34007', '34009', '34011', '34013', '34015', '34017', '34023', '34025', '34029', '34033', '34035', '34039', 
           '36005', '36011', '36013', '36027', '36029', '36045', '36047', '36055', '36059', '36061', '36063', '36071', 
           '36073', '36075', '36079', '36081', '36085', '36087', '36103', '36111', '36117', '36119', '37013', '37015', 
           '37019', '37029', '37031', '37041', '37049', '37053', '37055', '37073', '37091', '37095', '37103', '37129', 
           '37133', '37137', '37139', '37141', '37143', '37147', '37177', '37187', '39007', '39035', '39043', '39085',
           '39093', '39095', '39123', '39143', '41007', '41011', '41015', '41019', '41039', '41041', '41057', '42045', 
           '42049', '42101', '44001', '44003', '44005', '44007', '44009', '45013', '45015', '45019', '45029', '45035',
           '45043', '45049', '45051', '45053', '48007', '48039', '48057', '48061', '48071', '48167', '48201', '48239',
           '48245', '48261', '48273', '48321', '48355', '48361', '48391', '48409', '48469', '48489', '51001', '51013', 
           '51033', '51036', '51041', '51057', '51059', '51073', '51085', '51087', '51093', '51095', '51097', '51099',
           '51101', '51103', '51115', '51119', '51127', '51131', '51133', '51149', '51153', '51159', '51177', '51179',
           '51181', '51193', '51199', '51510', '51550', '51650', '51670', '51700', '51710', '51735', '51740', '51800',
           '51810', '51830', '53009', '53027', '53029', '53031', '53033', '53035', '53045', '53049', '53053', '53055', 
           '53057', '53061', '53067', '53069', '53073', '55003', '55007', '55009', '55029', '55031', '55051', '55059',
           '55061', '55071', '55075', '55079', '55083', '55089', '55101', '55117', '60010', '60020', '60050', '66010',
           '69085', '69100', '69110', '69120', '72003', '72005', '72011', '72013', '72015', '72017', '72021', '72023',
           '72027', '72031', '72033', '72037', '72049', '72051', '72053', '72055', '72057', '72059', '72061', '72065',
           '72069', '72071', '72075', '72079', '72087', '72089', '72091', '72095', '72097', '72103', '72109', '72111',
           '72113', '72115', '72117', '72119', '72123', '72127', '72133', '72137', '72143', '72145', '72147', '72151',
           '72153', '78010', '78020', '78030') # Using County Shoreline FIPS code
stringsAsFactors = FALSE 
#Check number of counties
nchar(fips)

# qcewGetAreaData : year, quarter, and area argument and
# returns an array containing the associated area data. use 'a' for annual
# averages. 
# For all area codes and titles see:
# http://data.bls.gov/cew/doc/titles/area/area_titles.htm

qcewGetAreaData <- function(year, qtr, area) {
  url <- "http://data.bls.gov/cew/data/api/YEAR/QTR/area/AREA.csv"
  url <- sub("YEAR", year, url, ignore.case=FALSE)
  url <- sub("AREA", toupper(area), url, ignore.case=FALSE)
  read.csv(url, header = TRUE, sep = ",", quote="\"", dec=".", na.strings=" ", skip=0)
}          

# SIC Data Extraction

# Define years for SIC data extraction
sic_years <- c(1975:2000)  # SIC Data Range begins 1975

# Test SIC Data
test_sic == sic_URL
sic_URL== sic_URL2
remove(test_sic,sic_URL,sic_URL2)
target_year <- 1990
test_sic <-"https://data.bls.gov/cew/data/files/1990/sic/csv/sic_1990_annual_by_area.zip"

# Loop for Data Extraction
for (target_year in sic_years) {
  for (fip in fips)
  sic_filename <- paste0(sic_prefix, target_year, sic_body)
  sic_URL <-
    paste0(base_URL,
           target_year,
           sic_subdirs,
           sic_filename,
           sic_extension)
  sic_local <- here("data", paste0(sic_filename, sic_extension))
   print(sic_URL)
  if (! file.exists(sic_local)) {
    download.file(sic_URL, sic_local)
  }
  file_list <- unzip(sic_local, list = TRUE)
  download_list <- file_list %>%
    filter(grepl(fips, Name))
  sfile <- unzip(
    sic_local,
    files = download_list$Name,
    junkpaths = TRUE,
    exdir = here("data", "tmp")
  ) %>%
    read_csv()
  glimpse(sfile)

#NAICS Data process
#Define the years for extractions for NAICS dataset
naic_years <- c(1990:2020)
# Test NAICS DATA

test_naic == naic_URL
naic_URL == naic_URL2
remove(test_naic, naic_URL, naic_URL2)

  for (target_year in naic_years) {
    for (fip in fips)
    naic_filename <- paste0(naic_prefix, target_year, naic_body)
    naic_URL <-
      paste0(base_URL,
             target_year,
             naic_subdirs,
             naic_filename,
             naic_extension)
    naic_local <- here("data", paste0(naic_filename, naic_extension))
     print(naic_URL)
    if (! file.exists(sic_local)) {
      download.file(naic_URL, naic_local)
    }
    file_list <- unzip(naic_local, list = TRUE)
    for (fip in fips) {
      needed_name <- file_list %>%
        filter(grepl(fips, Name))
      nfile <- unzip(
        naic_local,
        files = needed_name$Name,
        junkpaths = TRUE,
        exdir = here("data", "tmp")
      ) %>%
        read_csv()
      glimpse(nfile)
    }
  }
  
