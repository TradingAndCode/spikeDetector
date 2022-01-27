
#property copyright "Steven Nkeneng"
#property link "https://stevennkeneng.com"
#property strict

//3170564
//3542835 - hermann
//20323508 - darlin

if (TimeLocal() > D'01.04.2022' || AccountInfoInteger(ACCOUNT_LOGIN) != 3170564 )
{
   MessageBox("This File Has Expired! Please purchase the password from Steven nkeneng!", "Expired File");
   Print("This File Has Expired! Please purchase the password from Steven nkeneng!", "Expired File");
   Comment("The file was removed because it is past it's expiration date." +
           "\nPlease contact the programmer at nkeneng.steven@gmail.com for the password");
   ExpertRemove();
   return (INIT_FAILED);
}

if (!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
{
   MessageBox("You need to enable AutoTrading", "Please enable Autotrading!");
   Print("You need to enable AutoTrading", "Please enable Autotrading!");
   Comment(MQLInfoString(MQL_PROGRAM_NAME), "is NOT running because you have AutoTrading Disabled!" +
                                   "\nPlease Enable AutoTrading and reload the expert.");
   ExpertRemove();
   return (INIT_FAILED);
}
if (!MQLInfoInteger(MQL_TRADE_ALLOWED))
{
   MessageBox("You need to \"Allow Live Trading\"", "Please check \"Allow Live Trading\"!");
   Print("You need to \"Allow Live Trading\"", "Please check \"Allow Live Trading\"!");
   Comment(MQLInfoString(MQL_PROGRAM_NAME), "is NOT running because you do not have \"Allow Live Trading\" enabled!" +
                                   "\nPlease Enable \"Alow Live Trading\" and reload the expert.");
   ExpertRemove();
   return (INIT_FAILED);
}
if (!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
{
   MessageBox("DLLs are NOT enabled!", "Please enable DLLs!");
   Print("DLLs are NOT enabled!", "Please enable DLLs!");
   Comment(MQLInfoString(MQL_PROGRAM_NAME), "is NOT running because you have DLLs Disabled!" +
                                   "\nPlease Enable DLLs and reload the expert.");
   ExpertRemove();
   return (INIT_FAILED);
}
if (!MQLInfoInteger(MQL_DLLS_ALLOWED))
{
   MessageBox("Allow import of external experts is NOT enabled!", "Please enable it!");
   Print("Allow import of external experts is NOT enabled!", "Please enable it!");
   Comment(MQLInfoString(MQL_PROGRAM_NAME), "is NOT running because you have external experts Disabled!" +
                                   "\nPlease Enable them and reload the expert.");
   ExpertRemove();
   return (INIT_FAILED);
}
