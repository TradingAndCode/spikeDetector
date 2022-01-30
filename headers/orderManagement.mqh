
void CloseOrder(int positionIndex) // close trades opened longer than sec seconds
{
  bool success = false;
  int err = 0;
  int orderCount = 0;

  if (PositionGetTicket(positionIndex) <= 0)
    return;

  int ticket = (int)PositionGetInteger(POSITION_TICKET);

  if (!PositionSelectByTicket(ticket))
    return;

  int type = (int)PositionGetInteger(POSITION_TYPE);
  MqlTick last_tick;
  SymbolInfoTick(Symbol(), last_tick);
  double price = (type == ORDER_TYPE_SELL) ? last_tick.ask : last_tick.bid;
  MqlTradeRequest request;
  ZeroMemory(request);
  request.action = TRADE_ACTION_DEAL;
  request.position = ticket;

  // set allowed filling type
  int filling = (int)SymbolInfoInteger(Symbol(), SYMBOL_FILLING_MODE);

  if (request.action == TRADE_ACTION_DEAL && (filling & 1) != 1)
    request.type_filling = ORDER_FILLING_IOC;

  request.magic = MagicNumber;
  request.symbol = Symbol();
  request.volume = NormalizeDouble(PositionGetDouble(POSITION_VOLUME), LotDigits);

  if (NormalizeDouble(request.volume, LotDigits) == 0)
    return;

  request.price = NormalizeDouble(price, Digits());
  request.sl = 0;
  request.tp = 0;
  request.deviation = MaxSlippage_;
  request.type = (ENUM_ORDER_TYPE)(1 - type); // opposite type
  MqlTradeResult result;
  ZeroMemory(result);

  if (!OrderSend(request, result) || !OrderSuccess(result.retcode))
  {
    myAlert("error", "OrderClose failed; error: " + result.comment);
  }
  else
    myAlert("order", "Orders closed by duration: " + Symbol() + " Magic #" + IntegerToString(MagicNumber));
}

void MonitorRevenge()
{
  if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
    return;

  int total = PositionsTotal();
  double pnl = 0;
  for (int i = 0; i < total; i++)
  {
    if (PositionGetTicket(i) <= 0)
      continue;
    if (PositionGetInteger(POSITION_MAGIC) != MagicNumber || PositionGetString(POSITION_SYMBOL) != Symbol())
      continue;

    pnl += PositionGetDouble(POSITION_PROFIT);
    Print("current global profit ", pnl);
  }

  if (pnl >= 0)
  {
    // close all
    for (int i = 0; i < total; i++)
    {
      if (PositionGetTicket(i) <= 0)
        continue;
      if (PositionGetInteger(POSITION_MAGIC) != MagicNumber || PositionGetString(POSITION_SYMBOL) != Symbol())
        continue;
      CloseOrder(i);
    }
    Print("all trades close");
    // reset revenge
    revengeMode = false;
    lastTradeLot = 0;
    TradeSize = tradeVolume;
    lastMaxLot = 0;
  }
  else
  {
    revengeMode = true;
    lastTradeLot = NormalizeDouble(PositionGetDouble(POSITION_VOLUME), LotDigits);
  }
}

void MonitorTrades()
{

  if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
    return;

  int total = PositionsTotal();

  for (int i = 0; i < total; i++)
  {
    if (PositionGetTicket(i) <= 0)
      continue;

    if (PositionGetInteger(POSITION_MAGIC) != MagicNumber || PositionGetString(POSITION_SYMBOL) != Symbol() ||
        //
        PositionGetInteger(POSITION_TIME) + (PeriodSeconds()) > TimeCurrent() // more than one candle at least
                                                                              //
    )
      continue;

    if (PositionGetDouble(POSITION_PROFIT) > NormalizeDouble(0, LotDigits))
    {
      Print("trade in profit of ", PositionGetDouble(POSITION_PROFIT));
      if (PositionGetInteger(POSITION_TIME) + (MaxTradeDurationBars * PeriodSeconds()) <= TimeCurrent())
      {
        CloseOrder(i);
      }
    }
    else
    {
      revengeMode = true;
    }
  }

  if (revengeMode)
  {
    lastTradeLot = NormalizeDouble(PositionGetDouble(POSITION_VOLUME), LotDigits);
  }
}