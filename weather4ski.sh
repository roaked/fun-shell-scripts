# OpenWeatherMap API key  ######## Feel
API_KEY="YOUR_OPENWEATHERMAP_API_KEY"

# Declare an associative array of cities with populations for Austria and Switzerland
declare -A cities=(
    ["Vienna,at"]="1897491"
    ["Graz,at"]="280200"
    ["Linz,at"]="204846"
    ["Salzburg,at"]="155031"
    ["Innsbruck,at"]="132493"
    ["Zurich,ch"]="1395356"
    ["Geneva,ch"]="201818"
    ["Basel,ch"]="178015"
    ["Lausanne,ch"]="146372"
    ["Bern,ch"]="133798"
    ["Lucerne,ch"]="81292"
    ["St. Gallen,ch"]="75833"
    ["Stuttgart,de"]="632743"
    ["Konstanz,de"]="85404"
    # Add more cities here...
)

# Function to get the lowest temperature for a city
get_lowest_temperature() {
    local city_info=$1
    local city="${city_info%,*}" # Extracts the city name
    local country="${city_info#*,}" # Extracts the country code
    local population=${cities[$city_info]} # Retrieves population from the array

    forecast_data=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?q=${city},${country}&appid=${API_KEY}")

    # Get timestamps for the upcoming Saturday and Sunday
    saturday_timestamp=$(date -d "next Saturday" +%s)
    sunday_timestamp=$(date -d "next Sunday" +%s)

    # Extract temperatures for the upcoming weekend
    weekend_temperatures=$(echo "$forecast_data" | jq -r --argjson saturday_ts "$saturday_timestamp" --argjson sunday_ts "$sunday_timestamp" '.list[] | select(.dt >= $saturday_ts and .dt <= $sunday_ts) | .main.temp_min')

    # Calculate the lowest temperature for the weekend
    lowest_temperature=$(echo "$weekend_temperatures" | sort -n | head -n 1)

    echo "City: $city, Country: $country, Population: $population - Lowest temperature for the upcoming weekend: $lowest_temperature°C"
}

# Loop through cities and get lowest temperatures
for city_info in "${!cities[@]}"; do
    get_lowest_temperature "$city_info"
done

#chmod +x weather_script.sh
#./weather4ski.sh
