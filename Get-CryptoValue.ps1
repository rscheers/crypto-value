$ApiUrl = 'https://api.coinmarketcap.com/v1/ticker/'
$Wallet= @'
Name;Amount
bitcoin;2.3
monero;5.14
ripple;152
'@ | ConvertFrom-Csv -Delimiter ';'
$RefCurency = 'USD' #USD,EUR

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

$CurrencyFormat = New-Object System.Globalization.CultureInfo("en-US")

$Wallet| ForEach-Object -Process {
    $CurrentValueInUSD = ((Invoke-WebRequest -Uri "$($ApiUrl)$($_.Name)/?convert=$RefCurency" | Select-Object -ExpandProperty Content | ConvertFrom-Json) | Select-Object -ExpandProperty price_usd) -as [double]
    New-Object -TypeName PSObject -Property @{
        Currency = $_.Name
        ValueInUSD = $CurrentValueInUSD.ToString('c',$CurrencyFormat)
        ValueInWallet = ($CurrentValueInUSD * $_.Amount).ToString('c',$CurrencyFormat)
        Amount = $_.Amount
    }
    $CurrentValueInUSD = $null
} | ConvertTo-Html -PreContent $PreContent -PostContent $PostContent -Title 'Crypto Coin Dashboard' | Out-File -FilePath wallet.htm