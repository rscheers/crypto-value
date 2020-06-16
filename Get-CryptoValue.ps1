$APIKey = Get-Content .\APIKEY.TXT
#$APIURL = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?CMC_PRO_API_KEY=$($APIKey)"
$APIURL = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?CMC_PRO_API_KEY=$($APIKey)"

$Wallet = Import-Csv "wallet.csv" -Delimiter ";"

$RefCurrency = 'EUR' #USD,EUR

$PreContent = @'
<style>
table {
    border-collapse: collapse;
}
h2 {text-align:center}
th, td {
    padding: 8px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}
tr:hover{background-color:#f5f5f5}
</style>
<h1>Crypto Coin Dashboard</h1>
'@
$PostContent = @"
<br>
Last Refresh: $(Get-Date)
"@

$CurrencyFormat = New-Object System.Globalization.CultureInfo("nl-NL")

#$CurrentValueInUSD = Invoke-WebRequest -Uri "$($ApiUrl)&convert=$RefCurrency" | ConvertFrom-Json

$Wallet| ForEach-Object -Process {
    $CryptoCoinSymbol = $_.Symbol
    $CurrentValueInUSD = Invoke-WebRequest -Uri "$($ApiUrl)&convert=$RefCurrency&symbol=$Cryptocoinsymbol" | ConvertFrom-Json
    #$CurrentCryptoValue = ($CurrentValueInUSD.Data | Where-Object{$_.Symbol -eq ($CryptoCoin.symbol)}).quote.USD.price -as [double]
    $CurrentCryptoValue = $CurrentValueInUSD.Data.$CryptoCoinSymbol.quote.$RefCurrency.price -as [double]
    New-Object -TypeName PSObject -Property @{
        Currency = $_.Name
        ValueInUSD = $CurrentCryptoValue.ToString('c',$CurrencyFormat)
        ValueInWallet = ($CurrentCryptoValue * $_.Amount).ToString('c',$CurrencyFormat)
        Amount = $_.Amount
    }
    $CurrentCryptoValue = $null
} | ConvertTo-Html -PreContent $PreContent -PostContent $PostContent -Title 'Crypto Coin Dashboard' | Out-File -FilePath wallet.htm