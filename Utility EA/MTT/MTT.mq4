//+------------------------------------------------------------------+
//|                                     (Manual Trading Tool)MTT.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define PROFIT "PROFIT"
#define PRICE "PRICE"

string Currency[8];
string SYM[28];

int SymNo;
string suffix = StringSubstr(Symbol(),7);

long Chart_id = ChartID();
string Obj_Name = "MTT-";

string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
string Filename = terminal_data_path+"\\MQL4\\Files\\"+"mttpara.csv";
int Filehandle ;

double Buy_Profit = 0.00;
double Buy_Swap = 0.00;
int Buy_Order_No = 0;
double Buy_OpenPrice[];
double Buy_Size[];
double Buy_TP ;
double Buy_SL ;
bool Buy_TP_State ;
bool Buy_SL_State ;
double Sell_Profit = 0.00;
double Sell_Swap = 0.00;
int Sell_Order_No = 0;
double Sell_OpenPrice[];
double Sell_Size[];
double Sell_TP ;
double Sell_SL ;
long Sell_TP_State ;
long Sell_SL_State ;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ChartSetInteger(0,CHART_FOREGROUND,0,false);
   
   Currency[0] = "EUR"; Currency[1] = "GBP"; Currency[2] = "AUD"; Currency[3] = "NZD";
   Currency[4] = "USD"; Currency[5] = "CAD"; Currency[6] = "CHF"; Currency[7] = "JPY";
   
   int symno = 0;
   for(int i=0; i<8; i++)
   {
      for(int j=0; j<8; j++)
      {
         if(i<j)
         {
            SYM[symno] = Currency[i] + Currency[j] ;
            if(SYM[symno]==Symbol()) SymNo = symno ;
            //Print(SYM[symno]);
            symno++;
         }
      }
   }
   
   DASH_BOARD_BASE();
   ORDER_INFO();
   Print("Buy_Profit:",Buy_Profit,"/Buy_Swap:",Buy_Swap,"//Sell_Profit:",Sell_Profit,"/Sell_Swap:",Sell_Swap);
   DASHBOARD_UPDATE();
   
   OBJ_DELETE(Symbol()+"-OH-");
   ORDER_HISTORY_DRAW();
   //CLOSE_CONDITION();

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      OBJ_DELETE();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ORDER_INFO();
   DASHBOARD_UPDATE();
   
   CLOSE_CONDITION();
   
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id, 
                  const long &lparam, 
                  const double &dparam, 
                  const string &sparam)
{
//---
      if(id==CHARTEVENT_OBJECT_CLICK)
      {
         //Print(lparam,"  ",dparam,"  ",sparam);
         if(StringFind(sparam,Obj_Name+"DB-background")!=-1)
         {
            ObjectSetInteger(Chart_id,sparam,OBJPROP_STATE,false);
         }
         else if(StringFind(sparam,Obj_Name+"DB-button-")!=-1)
         {
            if(ObjectGetInteger(Chart_id,sparam,OBJPROP_STATE))
            {
               if(StringFind(sparam,"-tp-buy")!=-1 && StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-tp-buy-edit",OBJPROP_TEXT))>Buy_Profit)
               {
                  BUTTON_STATUS(true,"ON",sparam);
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-tp-buy-edit",OBJPROP_READONLY,true);
                  GlobalVariableSet(Symbol()+"-BUY-TP-STATE",true);
                  GlobalVariableSet(Symbol()+"-BUY-TP-VALUE",StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-tp-buy-edit",OBJPROP_TEXT)));
               }
               else if(StringFind(sparam,"-sl-buy")!=-1 && StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-sl-buy-edit",OBJPROP_TEXT))<Buy_Profit) 
               {
                  BUTTON_STATUS(true,"ON",sparam);
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-sl-buy-edit",OBJPROP_READONLY,true);
                  GlobalVariableSet(Symbol()+"-BUY-SL-STATE",true);
                  GlobalVariableSet(Symbol()+"-BUY-SL-VALUE",StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-sl-buy-edit",OBJPROP_TEXT)));
               }
               else if(StringFind(sparam,"-tp-sell")!=-1 && StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-tp-sell-edit",OBJPROP_TEXT))>Sell_Profit) 
               {
                  BUTTON_STATUS(true,"ON",sparam);
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-tp-sell-edit",OBJPROP_READONLY,true);
                  GlobalVariableSet(Symbol()+"-SELL-TP-STATE",true);
                  GlobalVariableSet(Symbol()+"-SELL-TP-VALUE",StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-tp-sell-edit",OBJPROP_TEXT)));
               }
               else if(StringFind(sparam,"-sl-sell")!=-1 && StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-sl-sell-edit",OBJPROP_TEXT))<Sell_Profit) 
               {
                  BUTTON_STATUS(true,"ON",sparam);
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-sl-sell-edit",OBJPROP_READONLY,true);
                  GlobalVariableSet(Symbol()+"-SELL-SL-STATE",true);
                  GlobalVariableSet(Symbol()+"-SELL-SL-VALUE",StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-sl-sell-edit",OBJPROP_TEXT)));
               }
               else ObjectSetInteger(Chart_id,sparam,OBJPROP_STATE,false);
            }
            else
            {
               BUTTON_STATUS(false,"OFF",sparam);
               
               if(StringFind(sparam,"-tp-buy")!=-1) 
               {
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-tp-buy-edit",OBJPROP_READONLY,false);
                  GlobalVariableSet(Symbol()+"-BUY-TP-STATE",false);
               }
               else if(StringFind(sparam,"-sl-buy")!=-1)
               {
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-sl-buy-edit",OBJPROP_READONLY,false);
                  GlobalVariableSet(Symbol()+"-BUY-SL-STATE",false);
               }
               else if(StringFind(sparam,"-tp-sell")!=-1) 
               {
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-tp-sell-edit",OBJPROP_READONLY,false);
                  GlobalVariableSet(Symbol()+"-SELL-TP-STATE",false);
               }
               else if(StringFind(sparam,"-sl-sell")!=-1) 
               {
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-sl-sell-edit",OBJPROP_READONLY,false);
                  GlobalVariableSet(Symbol()+"-SELL-SL-STATE",false);
               }
            }
         }
         else if(StringFind(sparam,Obj_Name+"DB-calc-line")!=-1)
         {
            if(ObjectGetInteger(Chart_id,sparam,OBJPROP_STATE))
            {
               if(StringFind(sparam,"-line-buy")!=-1)
               {
                  BUTTON_STATUS(true,"ON",sparam);
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-calc-buy-edit",OBJPROP_READONLY,false);
                  double profit_temp = StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-calc-buy-edit",OBJPROP_TEXT));
                  double price_temp = PROFIT_CALC(PRICE,"BUY",profit_temp);
                  Print("Price Calc Result = ",price_temp);
                  HLineCreate(Chart_id,Obj_Name+"DB-buy-profit-line",0,price_temp,clrBlue,STYLE_DASH,1,false,true,false);
               }
               else if(StringFind(sparam,"-line-sell")!=-1)
               {
                  BUTTON_STATUS(true,"ON",sparam);
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-calc-sell-edit",OBJPROP_READONLY,false);
                  double profit_temp = StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-calc-sell-edit",OBJPROP_TEXT));
                  double price_temp = PROFIT_CALC(PRICE,"SELL",profit_temp);
                  Print("Price Calc Result = ",price_temp);
                  HLineCreate(Chart_id,Obj_Name+"DB-sell-profit-line",0,price_temp,clrRed,STYLE_DASH,1,true,true,false);
               }
            }
            else
            {
               BUTTON_STATUS(false,"CREATE",sparam);
               
               if(StringFind(sparam,"-line-buy")!=-1) 
               {
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-calc-buy-edit",OBJPROP_READONLY,true);
                  OBJ_DELETE("buy-profit-line");
               }
               else if(StringFind(sparam,"-line-sell")!=-1) 
               {
                  ObjectSetInteger(Chart_id,Obj_Name+"DB-calc-sell-edit",OBJPROP_READONLY,true);
                  OBJ_DELETE("sell-profit-line");
               }
            }
         }
         else if(StringFind(sparam,Obj_Name+"DB-Minbox")!=-1)
         {
            OBJ_DELETE(Obj_Name+"DB-");
            OBJ_DELETE(Symbol()+"-OH-");
            int box_size = 30 ;
            ButtonCreate(Chart_id,Obj_Name+"DB-Maxbox",0,box_size+1,box_size+1,box_size,box_size,CORNER_RIGHT_LOWER,
                " ▲","Arial",12,clrGold,C'57,47,49',clrBlack,false,false,false,true,0);
         }
         else if(StringFind(sparam,Obj_Name+"DB-Maxbox")!=-1)
         {
            OBJ_DELETE(Obj_Name+"DB-Maxbox");
            OBJ_DELETE("-OH-");
            DASH_BOARD_BASE();
            ORDER_INFO();
            DASHBOARD_UPDATE();
            ORDER_HISTORY_DRAW();
         }
         
      }
      else if(id==CHARTEVENT_OBJECT_ENDEDIT)
      {
         if(sparam==Obj_Name+"DB-calc-sell-edit")
         {
            double profit_temp = StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-calc-sell-edit",OBJPROP_TEXT));
            double price_temp = PROFIT_CALC(PRICE,"SELL",profit_temp);
            Print("Price Calc Result = ",price_temp);
            ObjectSetDouble(Chart_id,Obj_Name+"DB-sell-profit-line",OBJPROP_PRICE,price_temp);
            //HLineCreate(Chart_id,Obj_Name+"sell-profit-line",0,price_temp,clrRed,STYLE_DASH,1,true,true,false);
         }
         else if(StringFind(sparam,Obj_Name+"DB-calc-buy-edit")!=-1)
         {
            double profit_temp = StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-calc-buy-edit",OBJPROP_TEXT));
            double price_temp = PROFIT_CALC(PRICE,"BUY",profit_temp);
            Print("Price Calc Result = ",price_temp);
            ObjectSetDouble(Chart_id,Obj_Name+"DB-buy-profit-line",OBJPROP_PRICE,price_temp);
            //HLineCreate(Chart_id,Obj_Name+"sell-profit-line",0,price_temp,clrRed,STYLE_DASH,1,true,true,false);
         }
      }
      else if(id==CHARTEVENT_OBJECT_DRAG)
      {
         if(sparam==Obj_Name+"DB-buy-profit-line")
         {
            double price_temp = ObjectGetDouble(Chart_id,sparam,OBJPROP_PRICE);
            double profit_temp = PROFIT_CALC(PROFIT,"BUY",price_temp);
            Print("Profit Calc Result = ",profit_temp);
            ObjectSetString(Chart_id,Obj_Name+"DB-calc-buy-edit",OBJPROP_TEXT,DoubleToStr(profit_temp,2));
         }
         else if(sparam==Obj_Name+"DB-sell-profit-line")
         {
            double price_temp = ObjectGetDouble(Chart_id,sparam,OBJPROP_PRICE);
            double profit_temp = PROFIT_CALC(PROFIT,"SELL",price_temp);
            Print("Profit Calc Result = ",profit_temp);
            ObjectSetString(Chart_id,Obj_Name+"DB-calc-sell-edit",OBJPROP_TEXT,DoubleToStr(profit_temp,2));
         }
      }
  
}
//------------------------End ChartEvent----------------------------------//

void ORDER_HISTORY_DRAW()
{

   int odh = OrdersHistoryTotal();
   
   for(int i=0; i<odh; i++)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) Print("OrderSelect returned the error of ",GetLastError());
      else
      {
         if(OrderSymbol()==Symbol() && OrderType()<6 && OrderCloseTime()>0)
         {
            if(OrderType()==OP_BUY)
            {
               DRAW_BUY_ARROW(Symbol()+"-OH-buy-open-"+i+"-",OrderOpenTime(),OrderOpenPrice(),clrBlue);
               DRAW_BUY_ARROW(Symbol()+"-OH-buy-close-"+i+"-",OrderCloseTime(),OrderClosePrice(),clrKhaki);
               DRAW_TRENDLINE(Symbol()+"-OH-buy-line-"+i+"-",OrderOpenTime(),OrderOpenPrice(),OrderCloseTime(),OrderClosePrice(),clrBlue);
               
            }
            if(OrderType()==OP_SELL)
            {
               DRAW_BUY_ARROW(Symbol()+"-OH-sell-open-"+i+"-",OrderOpenTime(),OrderOpenPrice(),clrRed);
               DRAW_BUY_ARROW(Symbol()+"-OH-sell-close-"+i+"-",OrderCloseTime(),OrderClosePrice(),clrKhaki);
               DRAW_TRENDLINE(Symbol()+"-OH-sell-line-"+i+"-",OrderOpenTime(),OrderOpenPrice(),OrderCloseTime(),OrderClosePrice(),clrRed);
            }
                                      // Draw arrow now 
            //Print("OrderType : ", OrderType(), " / OrderOpenTime : ", OrderOpenTime()," / OrderCloseTime : ", OrderCloseTime());
         }
      }
   }

}

void DRAW_BUY_ARROW(string objname, double time, double price, color col)
{
   if(!ObjectCreate(0,Obj_Name+objname+(string)time,OBJ_ARROW_BUY,0,time,price)) Print("Error: can't create buy arrow! code #",GetLastError(),objname);
   ObjectSetInteger(0,Obj_Name+objname+(string)time,OBJPROP_COLOR,col);
}
void DRAW_SELL_ARROW(string objname, double time, double price, color col)
{
   if(!ObjectCreate(0,Obj_Name+objname+(string)time,OBJ_ARROW_SELL,0,time,price)) Print("Error: can't create sell arrow! code #",GetLastError());
   ObjectSetInteger(0,Obj_Name+objname+(string)time,OBJPROP_COLOR,col);
}
void DRAW_TRENDLINE(string objname, double time1, double price1, double time2, double price2, color col)
{
   if(!ObjectCreate(0,Obj_Name+objname+(string)time1,OBJ_TREND,0,time1,price1,time2,price2)) Print("Error: can't create arrow! code #",GetLastError());
   ObjectSetInteger(0,Obj_Name+objname+(string)time1,OBJPROP_STYLE,STYLE_DASHDOT);
   ObjectSetInteger(0,Obj_Name+objname+(string)time1,OBJPROP_COLOR,col);
   ObjectSetInteger(0,Obj_Name+objname+(string)time1, OBJPROP_RAY_RIGHT, 0, FALSE) ;
}

double PROFIT_CALC(string type,string side, double value)
{
   double returnValue = 0 ;
   
   if(type==PRICE)
   {
      if(side=="BUY")
      {
         double funds = 0 ; double sizes = 0 ;
         for(int odNo=0; odNo<Buy_Order_No; odNo++)
         {
            funds += Buy_OpenPrice[odNo]*Buy_Size[odNo]*USD_VALUE_CONV() ;
            sizes += Buy_Size[odNo]*USD_VALUE_CONV() ;
         }
         if(sizes!=0) returnValue = (value + funds*100000) / sizes / 100000 ;
      }
      else if(side=="SELL")
      {
         double funds = 0 ; double sizes = 0 ;
         for(int odNo=0; odNo<Sell_Order_No; odNo++)
         {
            funds += Sell_OpenPrice[odNo]*Sell_Size[odNo]*USD_VALUE_CONV() ;
            sizes += Sell_Size[odNo]*USD_VALUE_CONV() ;
            //Print("Funds : ",funds," / Sizes : ",sizes);
         }
         if(sizes!=0) returnValue = (funds*100000 - value) / sizes / 100000 ;
      }
   }
   else if(type==PROFIT)
   {
      if(side=="BUY")
      {
         for(int odNo=0; odNo<Buy_Order_No; odNo++)
         {
            returnValue += (value-Buy_OpenPrice[odNo])*Buy_Size[odNo]*100000*USD_VALUE_CONV();
         }
      }
      else if(side=="SELL")
      {
         for(int odNo=0; odNo<Sell_Order_No; odNo++)
         {
            returnValue += (Sell_OpenPrice[odNo]-value)*Sell_Size[odNo]*100000*USD_VALUE_CONV();
         }
      }
   }
   
   return(returnValue);
}

double USD_VALUE_CONV()
{
   double returnValue=1 ;
   
   string price_currency = StringSubstr(Symbol(),3,6);
   
   if(price_currency == "GBP")
   {
      string symbol_name = "GBPUSD"+suffix;
      returnValue = MarketInfo(symbol_name,MODE_BID);
   }
   else if(price_currency == "AUD")
   {
      string symbol_name = "AUDUSD"+suffix;
      returnValue = MarketInfo(symbol_name,MODE_BID);
      Print(returnValue);
   }
   else if(price_currency == "NZD")
   {
      string symbol_name = "NZDUSD"+suffix;
      returnValue = MarketInfo(symbol_name,MODE_BID);
   }
   else if(price_currency == "USD")
   {
      returnValue = 1;
   }
   else if(price_currency == "CAD")
   {
      string symbol_name = "USDCAD"+suffix;
      returnValue = 1/MarketInfo(symbol_name,MODE_BID);
   }
   else if(price_currency == "CHF")
   {
      string symbol_name = "USDCHF"+suffix;
      returnValue = 1/MarketInfo(symbol_name,MODE_BID);
   }
   else if(price_currency == "JPY")
   {
      string symbol_name = "USDJPY"+suffix;
      returnValue = 1/MarketInfo(symbol_name,MODE_BID);
   }
   
   return(returnValue);
}

void BUTTON_STATUS(bool state, string text,string obj_name)
{
   if(state==true)
   {
      ObjectSetString(Chart_id,obj_name,OBJPROP_TEXT,text);
      ObjectSetInteger(Chart_id,obj_name,OBJPROP_COLOR,clrYellow);
      ObjectSetInteger(Chart_id,obj_name,OBJPROP_BORDER_COLOR,clrYellow);
   }
   else if(state==false)
   {
      ObjectSetString(Chart_id,obj_name,OBJPROP_TEXT,text);
      ObjectSetInteger(Chart_id,obj_name,OBJPROP_COLOR,clrSilver);
      ObjectSetInteger(Chart_id,obj_name,OBJPROP_BORDER_COLOR,clrBlack);
   }
}

void ORDER_INFO()
{
   Buy_Profit = 0; Sell_Profit = 0;
   Buy_Swap = 0; Sell_Swap = 0;
   Buy_Order_No = 0; Sell_Order_No = 0;
   ArrayResize(Buy_OpenPrice,OrdersTotal());
   ArrayResize(Buy_Size,OrdersTotal());
   ArrayResize(Sell_OpenPrice,OrdersTotal());
   ArrayResize(Sell_Size,OrdersTotal());
   
   
   for(int od_num=0; od_num<OrdersTotal(); od_num++)
   {
      if(!OrderSelect(od_num,SELECT_BY_POS))
      {
         Print(__FUNCTION__, 
            ": failed to select order! Error code = ",GetLastError()); 
      }
      else
      {
         if(OrderSymbol()==Symbol())
         {
            if(OrderType()==OP_BUY)
            {
               Buy_Profit += OrderProfit();
               Buy_Swap += OrderSwap();
               Buy_OpenPrice[Buy_Order_No] = OrderOpenPrice();
               Buy_Size[Buy_Order_No] = OrderLots();
               Buy_Order_No++;
            }
            else if(OrderType()==OP_SELL)
            {
               Sell_Profit += OrderProfit();
               Sell_Swap += OrderSwap();
               Sell_OpenPrice[Sell_Order_No] = OrderOpenPrice();
               Sell_Size[Sell_Order_No] = OrderLots();
               Sell_Order_No++;
            }
         }
      }
   }
}

void DASHBOARD_UPDATE()
{
   
   double temp_value[4]; string temp_string[4];
   temp_value[0]=Buy_Profit;   temp_string[0]="DB-profit-value-buy";
   temp_value[1]=Buy_Swap;     temp_string[1]="DB-swap-value-buy";
   temp_value[2]=Sell_Profit;  temp_string[2]="DB-profit-value-sell";
   temp_value[3]=Sell_Swap;    temp_string[3]="DB-swap-value-sell";
   //Print("Buy_Profit:",Buy_Profit,"/Buy_Swap:",Buy_Swap,"//Sell_Profit:",Sell_Profit,"/Sell_Swap:",Sell_Swap);
   for(int i=0; i<4; i++)
   {
      ObjectSetString(Chart_id,Obj_Name+temp_string[i],OBJPROP_TEXT,DoubleToStr(temp_value[i],2));
      if(temp_value[i]>0){ObjectSetInteger(Chart_id,Obj_Name+temp_string[i],OBJPROP_COLOR,clrRoyalBlue);}
      else if(temp_value[i]<0){ObjectSetInteger(Chart_id,Obj_Name+temp_string[i],OBJPROP_COLOR,clrCrimson);}
      else{ObjectSetInteger(Chart_id,Obj_Name+temp_string[i],OBJPROP_COLOR,clrWhite);}
   }


}

void CLOSE_CONDITION()
{
   Buy_TP = StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-tp-buy-edit",OBJPROP_TEXT));
   Buy_TP_State = ObjectGetInteger(Chart_id,Obj_Name+"DB-button-tp-buy",OBJPROP_STATE); //Print("Buy_TP_State:",Buy_TP_State);
   Buy_SL = StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-sl-buy-edit",OBJPROP_TEXT));
   Buy_SL_State = ObjectGetInteger(Chart_id,Obj_Name+"DB-button-sl-buy",OBJPROP_STATE);
   Sell_TP = StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-tp-sell-edit",OBJPROP_TEXT));
   Sell_TP_State = ObjectGetInteger(Chart_id,Obj_Name+"DB-button-tp-sell",OBJPROP_STATE);
   Sell_SL = StringToDouble(ObjectGetString(Chart_id,Obj_Name+"DB-sl-sell-edit",OBJPROP_TEXT));
   Sell_SL_State = ObjectGetInteger(Chart_id,Obj_Name+"DB-button-sl-sell",OBJPROP_STATE);
   
   
   if(Buy_Order_No>0)
   {
      if(Buy_TP_State && Buy_Profit > Buy_TP)
      {
         ORDER_CLOSE("TYPE",OP_BUY);
         Print("Buy TP Close. @",Bid," / Profit:",Buy_Profit);
         Buy_TP_State = false ;
         GlobalVariableSet(Symbol()+"-BUY-TP-STATE",false);
         BUTTON_STATUS(false,"OFF",Obj_Name+"DB-button-tp-buy");
         
      }
      else if(Buy_SL_State && Buy_Profit < Buy_SL)
      {
         ORDER_CLOSE("TYPE",OP_BUY);
         Print("Buy SL Close @",Bid," / Profit:",Buy_Profit);
         Buy_SL_State = false ;
         GlobalVariableSet(Symbol()+"-BUY-SL-STATE",false);
         BUTTON_STATUS(false,"OFF",Obj_Name+"DB-button-sl-buy");
      }
   }
   
   if(Sell_Order_No>0)
   {
      if(Sell_TP_State && Sell_Profit > Sell_TP)
      {
         ORDER_CLOSE("TYPE",OP_SELL);
         Print("Sell TP Close @",Ask," / Profit:",Sell_Profit);
         Sell_TP_State = false ;
         GlobalVariableSet(Symbol()+"-SELL-TP-STATE",false);
         BUTTON_STATUS(false,"OFF",Obj_Name+"DB-button-tp-sell");
      }
      else if(Sell_SL_State && Sell_Profit < Sell_SL)
      {
         ORDER_CLOSE("TYPE",OP_SELL);
         Print("Sell SL Close @",Ask," / Profit:",Sell_Profit);
         Sell_SL_State = false ;
         GlobalVariableSet(Symbol()+"-SELL-SL-STATE",false);
         BUTTON_STATUS(false,"OFF",Obj_Name+"DB-button-sl-sell");
      }
   }
   
}

bool ORDER_CLOSE(string close_type, int close_no)
{
   bool returnValue=false ;
   
   if(close_type == "TYPE")
   {
      for(int od_num=OrdersTotal()-1; od_num>=0; od_num--)
      {
         if(OrderSelect(od_num,SELECT_BY_POS))
         {
            if(OrderSymbol()==Symbol() && OrderType()==close_no)
            {
               double price = Bid ;
               if(OrderType()==OP_BUY) price = Bid;
               else if(OrderType()==OP_SELL) price = Ask;
               if(!OrderClose(OrderTicket(),OrderLots(),price,20,clrWhiteSmoke))
               {
                  Print(__FUNCTION__, 
                     ": failed to close order! Error code = ",GetLastError()); 
               }
               else{returnValue=True;}
            }
         }
         else
         {
            Print(__FUNCTION__, 
               ": failed to select order! Error code = ",GetLastError()); 
         }
      }
   }
   else if(close_type == "TICKET")
   {
      if(OrderSelect(close_no,SELECT_BY_TICKET))
      {
         double price = Bid ;
         if(OrderType()==OP_BUY) price = Bid;
         else if(OrderType()==OP_SELL) price = Ask;
         if(!OrderClose(OrderTicket(),OrderLots(),price,20,clrRoyalBlue))
         {
            Print(__FUNCTION__, 
               ": failed to close order! Error code = ",GetLastError()); 
         }
         else{returnValue=True;}
      }
      else
      {
         Print(__FUNCTION__, 
            ": failed to select order! Error code = ",GetLastError()); 
      }
   }
   
   return(returnValue);
}

void DASH_BOARD_BASE()
{
   Buy_TP_State = GlobalVariableGet(Symbol()+"-BUY-TP-STATE");
   if(Buy_TP_State) Buy_TP = GlobalVariableGet(Symbol()+"-BUY-TP-VALUE");
   Buy_SL_State = GlobalVariableGet(Symbol()+"-BUY-SL-STATE");
   if(Buy_SL_State) Buy_SL = GlobalVariableGet(Symbol()+"-BUY-SL-VALUE");
   Sell_TP_State = GlobalVariableGet(Symbol()+"-SELL-TP-STATE");
   if(Sell_TP_State) Sell_TP = GlobalVariableGet(Symbol()+"-SELL-TP-VALUE");
   Sell_SL_State = GlobalVariableGet(Symbol()+"-SELL-SL-STATE");
   if(Sell_SL_State) Sell_SL = GlobalVariableGet(Symbol()+"-SELL-SL-VALUE");
   
   int x_base = 300; int y_base = 330;
   int width = x_base/2; int height = 50;
   int button_size = 20;
   ButtonCreate(Chart_id,Obj_Name+"DB-background-1",0,x_base,y_base,x_base,y_base,CORNER_RIGHT_LOWER,
                "","Arial",10,clrBlack,C'57,47,49',clrBlack,false,false,false,true,0);
   ButtonCreate(Chart_id,Obj_Name+"DB-Minbox",0,button_size+1+x_base,button_size+1,button_size,button_size,CORNER_RIGHT_LOWER,
                " ▶","Arial",8,clrWhite,C'57,47,49',clrBlack,false,false,false,true,0);
   
   // Buy Side ---
   ButtonCreate(Chart_id,Obj_Name+"DB-background-buy-side",0,x_base,y_base,width,y_base,CORNER_RIGHT_LOWER,
                "","Arial",10,clrBlack,C'57,47,49',clrBlack,false,false,false,true,0);
   ButtonCreate(Chart_id,Obj_Name+"DB-background-buy-title",0,x_base,y_base,width,height,CORNER_RIGHT_LOWER,
                "BUY","Arial Black",12,clrRoyalBlue,C'57,47,49',clrBlack,false,false,false,true,0);
      // Buy Value ---
      LabelCreate(Chart_id,Obj_Name+"DB-profit-label-buy",0,x_base-10,y_base-height-10,CORNER_RIGHT_LOWER,
                   "PROFIT","Arial",10,clrWhiteSmoke,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      LabelCreate(Chart_id,Obj_Name+"DB-profit-value-buy",0,x_base-width+20,y_base-height-30,CORNER_RIGHT_LOWER,
                   "0.00","Arial",10,clrWhiteSmoke,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
      LabelCreate(Chart_id,Obj_Name+"DB-swap-label-buy",0,x_base-10,y_base-height-50,CORNER_RIGHT_LOWER,
                   "SWAP","Arial",10,clrWhiteSmoke,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      LabelCreate(Chart_id,Obj_Name+"DB-swap-value-buy",0,x_base-width+20,y_base-height-70,CORNER_RIGHT_LOWER,
                   "0.00","Arial",10,clrWhiteSmoke,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
      // Buy Edit ---
      LabelCreate(Chart_id,Obj_Name+"DB-tp-label-buy",0,x_base-10,y_base-height-100,CORNER_RIGHT_LOWER,
                   "Take Profit","Arial",10,clrWhiteSmoke,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      ButtonCreate(Chart_id,Obj_Name+"DB-button-tp-buy",0,x_base-width+55,y_base-height-100,40,17,CORNER_RIGHT_LOWER,
                   "OFF","Arial",9,clrSilver,C'128,128,128',clrBlack,false,false,false,true,0);
      EditCreate(Chart_id,Obj_Name+"DB-tp-buy-edit",0,x_base-10,y_base-height-120,width-25,30,
                 "0.00","Arial",10,ALIGN_RIGHT,false,CORNER_RIGHT_LOWER,clrWhiteSmoke,C'71,59,61',clrBlack,false,false,false,0);
      if(Buy_TP_State)
      {
         BUTTON_STATUS(true,"ON",Obj_Name+"DB-button-tp-buy");
         ObjectSetString(Chart_id,Obj_Name+"DB-tp-buy-edit",OBJPROP_TEXT,string(Buy_TP));
         ObjectSetInteger(Chart_id,Obj_Name+"DB-tp-buy-edit",OBJPROP_READONLY,true);
         ObjectSetInteger(Chart_id,Obj_Name+"DB-button-tp-buy",OBJPROP_STATE,true);
      }
      LabelCreate(Chart_id,Obj_Name+"DB-sl-label-buy",0,x_base-10,y_base-height-160,CORNER_RIGHT_LOWER,
                   "Stop Loss","Arial",10,clrWhiteSmoke,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      ButtonCreate(Chart_id,Obj_Name+"DB-button-sl-buy",0,x_base-width+55,y_base-height-160,40,17,CORNER_RIGHT_LOWER,
                   "OFF","Arial",9,clrSilver,C'128,128,128',clrBlack,false,false,false,true,0);
      EditCreate(Chart_id,Obj_Name+"DB-sl-buy-edit",0,x_base-10,y_base-height-180,width-25,30,
                 "0.00","Arial",10,ALIGN_RIGHT,false,CORNER_RIGHT_LOWER,clrWhiteSmoke,C'71,59,61',clrBlack,false,false,false,0);
      if(Buy_SL_State)
      {
         BUTTON_STATUS(true,"ON",Obj_Name+"DB-button-sl-buy");
         ObjectSetString(Chart_id,Obj_Name+"DB-sl-buy-edit",OBJPROP_TEXT,string(Buy_SL));
         ObjectSetInteger(Chart_id,Obj_Name+"DB-sl-buy-edit",OBJPROP_READONLY,true);
         ObjectSetInteger(Chart_id,Obj_Name+"DB-button-sl-buy",OBJPROP_STATE,true);
      }
      LabelCreate(Chart_id,Obj_Name+"DB-calc-label-buy",0,x_base-10,y_base-height-220,CORNER_RIGHT_LOWER,
                   "Profit Calc.","Arial",10,clrWhiteSmoke,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      ButtonCreate(Chart_id,Obj_Name+"DB-calc-line-buy",0,x_base-width+75,y_base-height-220,60,17,CORNER_RIGHT_LOWER,
                   "CREATE","Arial",9,clrSilver,C'128,128,128',clrBlack,false,false,false,true,0);
      EditCreate(Chart_id,Obj_Name+"DB-calc-buy-edit",0,x_base-10,y_base-height-240,width-25,30,
                 "0.00","Arial",10,ALIGN_RIGHT,false,CORNER_RIGHT_LOWER,clrWhiteSmoke,C'71,59,61',clrBlack,false,false,false,0);
              
   // Sell Side ---
   ButtonCreate(Chart_id,Obj_Name+"DB-background-sell-side",0,width,y_base,width,y_base,CORNER_RIGHT_LOWER,
                "","Arial",10,clrBlack,C'57,47,49',clrBlack,false,false,false,true,0);
   ButtonCreate(Chart_id,Obj_Name+"DB-background-sell-title",0,x_base-width,y_base,width,height,CORNER_RIGHT_LOWER,
                "SELL","Arial Black",12,clrCrimson,C'57,47,49',clrBlack,false,false,false,true,0);
      // Sell Value ---
      LabelCreate(Chart_id,Obj_Name+"DB-profit-label-sell",0,width-10,y_base-height-10,CORNER_RIGHT_LOWER,
                   "PROFIT","Arial",10,clrWhiteSmoke,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      LabelCreate(Chart_id,Obj_Name+"DB-profit-value-sell",0,20,y_base-height-30,CORNER_RIGHT_LOWER,
                   "0.00","Arial",10,clrWhiteSmoke,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
      LabelCreate(Chart_id,Obj_Name+"DB-swap-label-sell",0,width-10,y_base-height-50,CORNER_RIGHT_LOWER,
                   "SWAP","Arial",10,clrWhiteSmoke,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      LabelCreate(Chart_id,Obj_Name+"DB-swap-value-sell",0,20,y_base-height-70,CORNER_RIGHT_LOWER,
                   "0.00","Arial",10,clrWhiteSmoke,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
      // Sell Edit ---
      LabelCreate(Chart_id,Obj_Name+"DB-tp-label-sell",0,width-10,y_base-height-100,CORNER_RIGHT_LOWER,
                   "Take Profit","Arial",10,clrWhiteSmoke,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      ButtonCreate(Chart_id,Obj_Name+"DB-button-tp-sell",0,55,y_base-height-100,40,17,CORNER_RIGHT_LOWER,
                   "OFF","Arial",9,clrSilver,C'128,128,128',clrBlack,false,false,false,true,0);
      EditCreate(Chart_id,Obj_Name+"DB-tp-sell-edit",0,width-10,y_base-height-120,width-25,30,
                 "0.00","Arial",10,ALIGN_RIGHT,false,CORNER_RIGHT_LOWER,clrWhiteSmoke,C'71,59,61',clrBlack,false,false,false,0);
      if(Sell_TP_State)
      {
         BUTTON_STATUS(true,"ON",Obj_Name+"DB-button-tp-sell");
         ObjectSetString(Chart_id,Obj_Name+"DB-tp-sell-edit",OBJPROP_TEXT,string(Sell_TP));
         ObjectSetInteger(Chart_id,Obj_Name+"DB-tp-sell-edit",OBJPROP_READONLY,true);
         ObjectSetInteger(Chart_id,Obj_Name+"DB-button-tp-sell",OBJPROP_STATE,true);
      }
      LabelCreate(Chart_id,Obj_Name+"DB-sl-label-sell",0,width-10,y_base-height-160,CORNER_RIGHT_LOWER,
                   "Stop Loss","Arial",10,clrWhiteSmoke,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      ButtonCreate(Chart_id,Obj_Name+"DB-button-sl-sell",0,55,y_base-height-160,40,17,CORNER_RIGHT_LOWER,
                   "OFF","Arial",9,clrSilver,C'128,128,128',clrBlack,false,false,false,true,0);
      EditCreate(Chart_id,Obj_Name+"DB-sl-sell-edit",0,width-10,y_base-height-180,width-25,30,
                 "0.00","Arial",10,ALIGN_RIGHT,false,CORNER_RIGHT_LOWER,clrWhiteSmoke,C'71,59,61',clrBlack,false,false,false,0);
      if(Sell_SL_State)
      {
         BUTTON_STATUS(true,"ON",Obj_Name+"DB-button-sl-sell");
         ObjectSetString(Chart_id,Obj_Name+"DB-sl-sell-edit",OBJPROP_TEXT,string(Sell_SL));
         ObjectSetInteger(Chart_id,Obj_Name+"DB-sl-sell-edit",OBJPROP_READONLY,true);
         ObjectSetInteger(Chart_id,Obj_Name+"DB-button-sl-sell",OBJPROP_STATE,true);
      }
      LabelCreate(Chart_id,Obj_Name+"DB-calc-label-sell",0,width-10,y_base-height-220,CORNER_RIGHT_LOWER,
                   "Profit Calc.","Arial",10,clrWhiteSmoke,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      ButtonCreate(Chart_id,Obj_Name+"DB-calc-line-sell",0,75,y_base-height-220,60,17,CORNER_RIGHT_LOWER,
                   "CREATE","Arial",9,clrSilver,C'128,128,128',clrBlack,false,false,false,true,0);
      EditCreate(Chart_id,Obj_Name+"DB-calc-sell-edit",0,width-10,y_base-height-240,width-25,30,
                 "0.00","Arial",10,ALIGN_RIGHT,false,CORNER_RIGHT_LOWER,clrWhiteSmoke,C'71,59,61',clrBlack,false,false,false,0);
              
}


void OBJ_DELETE(string objname="")
{
   
   int objTotal = ObjectsTotal();
   //Print("object Total No.: ",objTotal);
   for(int i=objTotal-1; i>=0; i--)
   {
      string name = ObjectName(i);
      if(objname=="")
      {
         //PrintFormat("%d object name: %s",i,name);
         ObjectDelete(0,name);
      }
      else
      {
         if(StringFind(name,objname)!=-1)
         {
            ObjectDelete(0,name);
         }
         
      }
   }
   
}



//+------------------------------------------------------------------+ 
//| Create the button                                                | 
//+------------------------------------------------------------------+ 
bool ButtonCreate(const long              chart_ID=0,               // chart's ID 
                  const string            name="Button",            // button name 
                  const int               sub_window=0,             // subwindow index 
                  const int               x=0,                      // X coordinate 
                  const int               y=0,                      // Y coordinate 
                  const int               width=50,                 // button width 
                  const int               height=18,                // button height 
                  const ENUM_BASE_CORNER  corner=CORNER_RIGHT_LOWER, // chart corner for anchoring 
                  const string            text="Button",            // text 
                  const string            font="Arial",             // font 
                  const int               font_size=10,             // font size 
                  const color             clr=clrBlack,             // text color 
                  const color             back_clr=C'236,233,216',  // background color 
                  const color             border_clr=clrNONE,       // border color 
                  const bool              state=false,              // pressed/released 
                  const bool              back=false,               // in the background 
                  const bool              selection=false,          // highlight to move 
                  const bool              hidden=true,              // hidden in the object list 
                  const long              z_order=0)                // priority for mouse click 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- create the button 
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create the button! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set button coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
//--- set button size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- set button state 
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state); 
//--- enable (true) or disable (false) the mode of moving the button by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 

//+------------------------------------------------------------------+ 
//| Create a text label                                              | 
//+------------------------------------------------------------------+ 
bool LabelCreate(const long              chart_ID=0,               // chart's ID 
                 const string            name="Label",             // label name 
                 const int               sub_window=0,             // subwindow index 
                 const int               x=0,                      // X coordinate 
                 const int               y=0,                      // Y coordinate 
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                 const string            text="Label",             // text 
                 const string            font="Arial",             // font 
                 const int               font_size=10,             // font size 
                 const color             clr=clrRed,               // color 
                 const double            angle=0.0,                // text slope 
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                 const bool              back=false,               // in the background 
                 const bool              selection=false,          // highlight to move 
                 const bool              hidden=true,              // hidden in the object list 
                 const long              z_order=0)                // priority for mouse click 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- create a text label 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create text label! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- set the slope angle of the text 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); 
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
  
//+------------------------------------------------------------------+ 
//| Create Edit object                                               | 
//+------------------------------------------------------------------+ 
bool EditCreate(const long             chart_ID=0,               // chart's ID 
                const string           name="Edit",              // object name 
                const int              sub_window=0,             // subwindow index 
                const int              x=0,                      // X coordinate 
                const int              y=0,                      // Y coordinate 
                const int              width=50,                 // width 
                const int              height=18,                // height 
                const string           text="Text",              // text 
                const string           font="Arial",             // font 
                const int              font_size=10,             // font size 
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type 
                const bool             read_only=false,          // ability to edit 
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                const color            clr=clrBlack,             // text color 
                const color            back_clr=clrWhite,        // background color 
                const color            border_clr=clrNONE,       // border color 
                const bool             back=false,               // in the background 
                const bool             selection=false,          // highlight to move 
                const bool             hidden=true,              // hidden in the object list 
                const long             z_order=0)                // priority for mouse click 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- create edit field 
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create \"Edit\" object! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set object coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
//--- set object size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- set the type of text alignment in the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align); 
//--- enable (true) or cancel (false) read-only mode 
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only); 
//--- set the chart's corner, relative to which object coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
  
  
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  { 
//--- if the price is not set, set it at the current Bid price level 
   if(!price) 
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- reset the error value 
   ResetLastError(); 
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a horizontal line! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
  
//+------------------------------------------------------------------+ 
//| Create a trend line by the given coordinates                     | 
//+------------------------------------------------------------------+ 
bool TrendCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="TrendLine",  // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time1=0,           // first point time 
                 double                price1=0,          // first point price 
                 datetime              time2=0,           // second point time 
                 double                price2=0,          // second point price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            ray_right=false,   // line's continuation to the right 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  { 
//--- set anchor points' coordinates if they are not set 
   //ChangeTrendEmptyPoints(time1,price1,time2,price2); 
//--- reset the error value 
   ResetLastError(); 
//--- create a trend line by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a trend line! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 