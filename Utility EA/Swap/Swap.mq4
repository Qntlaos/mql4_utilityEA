//+------------------------------------------------------------------+
//|                                                         Swap.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window


string Currency[8] = {"EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY"};
string SYM[28];
string suffix = StringSubstr(Symbol(),7);
string Object_name = "swap_dashboard";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SYMBOL_INI();
   
   SWAP_OBJ_CREATE();
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   
   for(int i=0; i<28; i++) SWAP_OBJ_UPDATE(i);
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

void OnChartEvent(const int id, 
                  const long &lparam, 
                  const double &dparam, 
                  const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(StringFind(sparam,Object_name)!=-1)
      {
         ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
         if(StringFind(sparam,Object_name+"-Sym-")!=-1)
         {
            int sym = int(StringSubstr(sparam,StringLen(Object_name+"-Sym-"),2));
            ChartSetSymbolPeriod(0,SYM[sym]+suffix,0);
         }
      }
   }
}

void OnDeinit(const int reason)
{
   OBJ_DELETE();
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

void SYMBOL_INI()
{
   int symbol_no = 0;
   for(int i=0; i<8; i++)
   {
      for(int j=0; j<8; j++)
      {
         if(j>i)
         {
            SYM[symbol_no] = Currency[i] + Currency[j];
            //Print(symbol_no,"-",SYM[symbol_no]);
            symbol_no++;
         }
      }
   }
}

void SWAP_OBJ_CREATE()
{
   int x_base = 10; 
   int y_base = 20;
   int button_width = 80;
   int button_heigh = 18;
   
   ButtonCreate(0,Object_name+"-Sym-Title",0,x_base,y_base,button_width,button_heigh,CORNER_LEFT_UPPER,"Symbol","Arial Black",10,
               clrWhite,clrBlack);
   ButtonCreate(0,Object_name+"-SwapLong-Title",0,x_base+100,y_base,button_width+100,button_heigh,CORNER_LEFT_UPPER,"Swap Long","Arial",10,
               clrWhite,clrBlack);
   ButtonCreate(0,Object_name+"-SwapShort-Title",0,x_base+300,y_base,button_width+100,button_heigh,CORNER_LEFT_UPPER,"Swap Short","Arial",10,
               clrWhite,clrBlack);
   
   for(int symNo=0; symNo<28; symNo++)
   {
      color swaplong_clr = (MarketInfo(SYM[symNo],MODE_SWAPLONG))>0?clrRoyalBlue:clrCrimson;
      color swapshort_clr = (MarketInfo(SYM[symNo],MODE_SWAPSHORT))>0?clrRoyalBlue:clrCrimson;
      
      ButtonCreate(0,Object_name+"-Sym-"+(string)symNo,0,x_base,y_base*(symNo+2),button_width,button_heigh,CORNER_LEFT_UPPER,SYM[symNo],"Arial Black",10,
                  clrGray,clrBlack);
      ButtonCreate(0,Object_name+"-SwapLong-"+(string)symNo,0,x_base+100,y_base*(symNo+2),button_width+100,button_heigh,CORNER_LEFT_UPPER,(string)MarketInfo(SYM[symNo],MODE_SWAPLONG),"Arial",10,
                  swaplong_clr,clrBlack);
      ButtonCreate(0,Object_name+"-SwapShort-"+(string)symNo,0,x_base+300,y_base*(symNo+2),button_width+100,button_heigh,CORNER_LEFT_UPPER,(string)MarketInfo(SYM[symNo],MODE_SWAPSHORT),"Arial",10,
                  swapshort_clr,clrBlack);
   }
}

void SWAP_OBJ_UPDATE(int symNo)
{
   color swaplong_clr = (MarketInfo(SYM[symNo],MODE_SWAPLONG))>0?clrRoyalBlue:clrCrimson;
   color swapshort_clr = (MarketInfo(SYM[symNo],MODE_SWAPSHORT))>0?clrRoyalBlue:clrCrimson;
   
   ObjectSetString(0,Object_name+"-SwapLong-"+(string)symNo,OBJPROP_TEXT,(string)MarketInfo(SYM[symNo],MODE_SWAPLONG));
   ObjectSetInteger(0,Object_name+"-SwapLong-"+(string)symNo,OBJPROP_COLOR,swaplong_clr);
   ObjectSetString(0,Object_name+"-SwapShort-"+(string)symNo,OBJPROP_TEXT,(string)MarketInfo(SYM[symNo],MODE_SWAPSHORT));
   ObjectSetInteger(0,Object_name+"-SwapShort-"+(string)symNo,OBJPROP_COLOR,swapshort_clr);
   
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
