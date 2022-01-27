

void myAlert(string type, string message)
{
    if (type == "print")
        Print(message);
    else if (type == "error")
    {
        Print(type + " | spikeDetector @ " + Symbol() + "," + IntegerToString(Period()) + " | " + message);
    }
    else if (type == "order")
    {
    }
    else if (type == "modify")
    {
    }
}

double MM_Size(double SL) //Risk % per trade, SL = relative Stop Loss to calculate risk
  {
   double MaxLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   double MinLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   double tickvalue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
   double ticksize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double lots = MM_Percent * 1.0 / 100 * AccountInfoDouble(ACCOUNT_BALANCE) / (SL / ticksize * tickvalue);
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }


int TradesCount(ENUM_ORDER_TYPE type) //returns # of open trades for order type, current symbol and magic number
  {
   if(type <= 1)
     {
      int result = 0;
      int total = PositionsTotal();
      for(int i = 0; i < total; i++)
        {
         if(PositionGetTicket(i) <= 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != MagicNumber || PositionGetString(POSITION_SYMBOL) != Symbol() || PositionGetInteger(POSITION_TYPE) != type) continue;
         result++;
        }
      return(result);
     }
   else
     {
      int result = 0;
      int total = OrdersTotal();
      for(int i = 0; i < total; i++)
        {
         if(OrderGetTicket(i) <= 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) != MagicNumber || OrderGetString(ORDER_SYMBOL) != Symbol() || OrderGetInteger(ORDER_TYPE) != type) continue;
         result++;
        }
      return(result);
     }
  }