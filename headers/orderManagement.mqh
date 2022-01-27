
void CloseByDuration(int positionIndex) // close trades opened longer than sec seconds
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

void MonitorTrades(int sec)
{
  if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
    return;

  int total = PositionsTotal();
  for (int i = 0; i < total; i++)
  {
    if (PositionGetTicket(i) <= 0)
      continue;
    if (PositionGetInteger(POSITION_MAGIC) != MagicNumber || PositionGetString(POSITION_SYMBOL) != Symbol() || PositionGetInteger(POSITION_TIME) + sec > TimeCurrent())
      continue;

    if (PositionGetDouble(POSITION_PROFIT) > NormalizeDouble(0, LotDigits))
    {
      Print("trade in profit of ", PositionGetDouble(POSITION_PROFIT));
      CloseByDuration(i);
    }
    else
    {
      revengeMode = true;
    }
  }
}