//+------------------------------------------------------------------+
//|                                     mql5_signal_history_load.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


input string FileName = "(GoodInvest)426952.history.csv" ;
input int GMT = 2; 
string Obj_Name = "signal_history_load";

struct readData
{
   datetime ld_OpenTime;
   string ld_Type;
   double ld_Volume;
   string ld_Symbol;
   double ld_OpenPrice;
   double ld_StopLoss;
   double ld_TakeProfit;
   datetime ld_CloseTime;
   double ld_ClosePrice;
   double ld_Commission;
   double ld_Swap;
   double ld_Profit;   
   string ld_Comment;
};


//datetime ld_OpenTime[],ld_CloseTime[];
//string ld_Type[],ld_Symbol[],ld_Comment[];
//double ld_Volume[],ld_OpenPrice[],ld_ClosePrice[],ld_Commission[],ld_Swap[],ld_Profit[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
   readData arr[1];
   
   string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH); 
   string filename=terminal_data_path+"\\MQL4\\Files\\"+FileName; 
   
   ResetLastError();
   int filehandle=FileOpen(FileName,FILE_READ|FILE_CSV); 
   if(filehandle!=INVALID_HANDLE) 
   { 
      TITLE_LOAD(filehandle);
      int od = 0;
      while(!FileIsEnding(filehandle))
      {
         DATA_LOAD(filehandle,arr,od);
         od++;   
      }
   } 
   else Print("Operation FileOpen failed, error ",GetLastError()); 

   FileClose(filehandle);  

      
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
   
  }
//+------------------------------------------------------------------+

void TITLE_LOAD(int file_handle)
{
   string OpenTime = FileReadString(file_handle);
   string Type = FileReadString(file_handle);
   string Volume1 = FileReadString(file_handle);
   string Symbol1 = FileReadString(file_handle);
   string OpenPrice = FileReadString(file_handle);
   string StopLoss = FileReadString(file_handle);
   string TakeProfit = FileReadString(file_handle);
   string CloseTime = FileReadString(file_handle);
   string ClosePrice = FileReadString(file_handle);
   string Commission = FileReadString(file_handle);
   string Swap = FileReadString(file_handle);
   string Profit = FileReadString(file_handle);
   string Comment1 = FileReadString(file_handle);
   
   Print(
   OpenTime,",",
   Type,",",
   Volume1,",",
   Symbol1,",",
   OpenPrice,",",
   StopLoss,",",
   TakeProfit,",",
   CloseTime,",",
   ClosePrice,",",
   Commission,",",
   Swap,",",
   Profit,",",
   Comment1);
}

void DATA_LOAD(int file_handle, readData &arr[], int i)
{
   ArrayResize(arr,i+1);
   
   arr[i].ld_OpenTime = FileReadDatetime(file_handle)-GMT*3600;
   arr[i].ld_Type = FileReadString(file_handle);
   arr[i].ld_Volume = StringToDouble(FileReadString(file_handle));
   arr[i].ld_Symbol = StringSubstr(FileReadString(file_handle),0,6);
   arr[i].ld_OpenPrice = StringToDouble(FileReadString(file_handle));
   arr[i].ld_StopLoss = StringToDouble(FileReadString(file_handle));
   arr[i].ld_TakeProfit = StringToDouble(FileReadString(file_handle));
   arr[i].ld_CloseTime = FileReadDatetime(file_handle)-GMT*3600;
   arr[i].ld_ClosePrice = StringToDouble(FileReadString(file_handle));
   arr[i].ld_Commission = StringToDouble(FileReadString(file_handle));
   arr[i].ld_Swap = StringToDouble(FileReadString(file_handle));
   arr[i].ld_Profit = StringToDouble(FileReadString(file_handle));
   arr[i].ld_Comment = FileReadString(file_handle);
   
   ArrayResize(arr,i+1);
   
   /*
   Print("OpenTime:",arr[i].ld_OpenTime,
         ", Type:",arr[i].ld_Type,
         ", Volume:",arr[i].ld_Volume,
         ", Symbol:",arr[i].ld_Symbol,
         ", Price:",arr[i].ld_OpenPrice,
         ", sl:",arr[i].ld_StopLoss,
         ", tp:",arr[i].ld_TakeProfit,
         ", CloseTime:",arr[i].ld_CloseTime,
         ", Price:",arr[i].ld_ClosePrice,
         ", Commission:",arr[i].ld_Commission,
         ", Swap:",arr[i].ld_Swap,
         ", Profit:",arr[i].ld_Profit,
         ", Comment:",arr[i].ld_Comment);
   */
   ORDER_HISTORY_DRAW(arr,i);
}

void ORDER_HISTORY_DRAW(readData &arr[], int odNo)
{
   //Print(arr[odNo].ld_Symbol,",",arr[odNo].ld_Type);
   if(arr[odNo].ld_Symbol == Symbol())
   {
      if(arr[odNo].ld_Type == "Buy")
      {
         DRAW_BUY_ARROW(Symbol()+"-OH-buy-open",arr[odNo].ld_OpenTime,arr[odNo].ld_OpenPrice,clrBlue);
         DRAW_BUY_ARROW(Symbol()+"-OH-buy-close",arr[odNo].ld_CloseTime,arr[odNo].ld_ClosePrice,clrKhaki);
         DRAW_TRENDLINE(Symbol()+"-OH-buy-line",arr[odNo].ld_OpenTime,arr[odNo].ld_OpenPrice,arr[odNo].ld_CloseTime,arr[odNo].ld_ClosePrice,clrBlue);
         DRAW_PROFIT(Symbol()+"-OH-buy-profit",arr[odNo].ld_CloseTime,arr[odNo].ld_ClosePrice,arr[odNo].ld_Profit,clrWhite);
      }
      else if(arr[odNo].ld_Type == "Sell")
      {
         DRAW_SELL_ARROW(Symbol()+"-OH-sell-open",arr[odNo].ld_OpenTime,arr[odNo].ld_OpenPrice,clrRed);
         DRAW_SELL_ARROW(Symbol()+"-OH-sell-close",arr[odNo].ld_CloseTime,arr[odNo].ld_ClosePrice,clrKhaki);
         DRAW_TRENDLINE(Symbol()+"-OH-sell-line",arr[odNo].ld_OpenTime,arr[odNo].ld_OpenPrice,arr[odNo].ld_CloseTime,arr[odNo].ld_ClosePrice,clrRed);
         DRAW_PROFIT(Symbol()+"-OH-sell-profit",arr[odNo].ld_CloseTime,arr[odNo].ld_ClosePrice,arr[odNo].ld_Profit,clrWhite);
      }
   }
   
}

void DRAW_BUY_ARROW(string objname, double time, double price, color col)
{
   if(ObjectFind(0,Obj_Name+objname+(string)time))ObjectCreate(0,Obj_Name+objname+(string)time,OBJ_ARROW_BUY,0,time,price);
   ObjectSetInteger(0,Obj_Name+objname+(string)time,OBJPROP_COLOR,col);
}
void DRAW_SELL_ARROW(string objname, double time, double price, color col)
{
   if(ObjectFind(0,Obj_Name+objname+(string)time))ObjectCreate(0,Obj_Name+objname+(string)time,OBJ_ARROW_SELL,0,time,price);
   ObjectSetInteger(0,Obj_Name+objname+(string)time,OBJPROP_COLOR,col);
}
void DRAW_TRENDLINE(string objname, double time1, double price1, double time2, double price2, color col)
{
   if(ObjectFind(0,Obj_Name+objname+(string)time1))ObjectCreate(0,Obj_Name+objname+(string)time1,OBJ_TREND,0,time1,price1,time2,price2);
   ObjectSetInteger(0,Obj_Name+objname+(string)time1,OBJPROP_STYLE,STYLE_DASHDOT);
   ObjectSetInteger(0,Obj_Name+objname+(string)time1,OBJPROP_COLOR,col);
   ObjectSetInteger(0,Obj_Name+objname+(string)time1, OBJPROP_RAY_RIGHT, 0, FALSE) ;
}
void DRAW_PROFIT(string objname, double time, double price, double profit, color col)
{
   col = (profit>=0)?clrGold:clrRed; 
   price = price + MathPow(10,-Digits())*150 ;
   if(ObjectFind(0,Obj_Name+objname+(string)time))TextCreate(0,Obj_Name+objname+(string)time,0,time,price,(string)profit,"Arial",10,col);
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
//| Creating Text object                                             | 
//+------------------------------------------------------------------+ 
bool TextCreate(const long              chart_ID=0,               // chart's ID 
                const string            name="Text",              // object name 
                const int               sub_window=0,             // subwindow index 
                datetime                time=0,                   // anchor point time 
                double                  price=0,                  // anchor point price 
                const string            text="Text",              // the text itself 
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
//--- set anchor point coordinates if they are not set 
   //ChangeTextEmptyPoint(time,price); 
//--- reset the error value 
   ResetLastError(); 
//--- create Text object 
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create \"Text\" object! Error code = ",GetLastError()); 
      return(false); 
     } 
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
//--- enable (true) or disable (false) the mode of moving the object by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
}