

bool LotFreeMarginCorrect(
    string symbol,
    double &Lot,
    ENUM_POSITION_TYPE trade_operation)
{
    double freemargin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
    if (freemargin <= 0)
        return (false);
    double LOTSTEP = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    double MinLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    if (!LOTSTEP || !MinLot)
        return (0);
    double maxLot = GetLotForOpeningPos(symbol, trade_operation, freemargin);
    //---- нормирование величины лота до ближайшего стандартного значения
    maxLot = LOTSTEP * MathFloor(maxLot / LOTSTEP);
    if (maxLot < MinLot)
        return (false);
    if (Lot > maxLot)
        Lot = maxLot;
    //----
    return (true);
}

double LotCount(
    string symbol,
    ENUM_POSITION_TYPE postype,
    double Money_Management)
{
    double margin, Lot;
    margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE) * Money_Management;
    if (!margin)
        return (-1);

    Lot = GetLotForOpeningPos(symbol, postype, margin);

    if (!LotCorrect(symbol, Lot, postype))
        return (-1);
    return (Lot);
}

bool LotCorrect(
    string symbol,
    double &Lot,
    ENUM_POSITION_TYPE trade_operation)
{

    double LOTSTEP = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    double MaxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double MinLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);

    if (!LOTSTEP || !MaxLot || !MinLot)
        return (0);

    Lot = LOTSTEP * MathFloor(Lot / LOTSTEP);

    if (Lot < MinLot)
        Lot = MinLot;
    if (Lot > MaxLot)
        Lot = MaxLot;

    if (!LotFreeMarginCorrect(symbol, Lot, trade_operation))
        return (false);
        
    return (true);
}

double GetLotForOpeningPos(string symbol, ENUM_POSITION_TYPE direction, double lot_margin)
{
    //----
    double price = 0.0, n_margin;
    if (direction == POSITION_TYPE_BUY)
        price = SymbolInfoDouble(symbol, SYMBOL_ASK);
    if (direction == POSITION_TYPE_SELL)
        price = SymbolInfoDouble(symbol, SYMBOL_BID);
    if (!price)
        return (NULL);

    if (!OrderCalcMargin(ENUM_ORDER_TYPE(direction), symbol, 1, price, n_margin) || !n_margin)
        return (0);
    double lot = lot_margin / n_margin;

    double LOTSTEP = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    double MaxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double MinLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    if (!LOTSTEP || !MaxLot || !MinLot)
        return (0);

    lot = LOTSTEP * MathFloor(lot / LOTSTEP);

    if (lot < MinLot)
        lot = 0;

    if (lot > MaxLot)
        lot = MaxLot;

    return (lot);
}