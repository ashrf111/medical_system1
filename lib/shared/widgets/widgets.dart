import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/theme.dart';

// ─── Btn ─────────────────────────────────────────────────────────────────────
class Btn extends StatelessWidget {
  final String label; final VoidCallback? onTap; final bool loading;
  final double? width; final Color? color;
  const Btn({super.key, required this.label, this.onTap, this.loading=false, this.width, this.color});
  @override Widget build(BuildContext ctx) => SizedBox(width: width??double.infinity, height: 50,
    child: ElevatedButton(onPressed: loading?null:onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color??C.primary, disabledBackgroundColor: C.border),
      child: loading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2.5)) : Text(label)));
}

class OBtn extends StatelessWidget {
  final String label; final VoidCallback? onTap;
  const OBtn({super.key, required this.label, this.onTap});
  @override Widget build(BuildContext ctx) => SizedBox(width:double.infinity,height:50,child:OutlinedButton(onPressed:onTap,child:Text(label)));
}

// ─── Input ───────────────────────────────────────────────────────────────────
class Inp extends StatelessWidget {
  final String label, hint; final TextEditingController ctrl;
  final bool obs; final TextInputType kb; final String? Function(String?)? validator;
  final Widget? suffix; final Widget? prefix; final int lines;
  final List<TextInputFormatter>? fmt; final void Function(String)? onChange;
  const Inp({super.key, required this.label, required this.hint, required this.ctrl,
    this.obs=false, this.kb=TextInputType.text, this.validator, this.suffix,
    this.prefix, this.lines=1, this.fmt, this.onChange});
  @override Widget build(BuildContext ctx) => Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
    Text(label, style:label_style),
    const SizedBox(height:6),
    TextFormField(controller:ctrl, obscureText:obs, keyboardType:kb, validator:validator,
      maxLines:lines, inputFormatters:fmt, onChanged:onChange,
      decoration:InputDecoration(hintText:hint, suffixIcon:suffix, prefixIcon:prefix)),
  ]);
}

// ─── Card ────────────────────────────────────────────────────────────────────
class MCard extends StatelessWidget {
  final Widget child; final EdgeInsetsGeometry? pad; final Color? bg; final VoidCallback? onTap;
  const MCard({super.key, required this.child, this.pad, this.bg, this.onTap});
  @override Widget build(BuildContext ctx) => Material(
    color: bg??C.card, borderRadius: BorderRadius.circular(12),
    child: InkWell(onTap:onTap, borderRadius:BorderRadius.circular(12),
      child: Container(padding:pad??const EdgeInsets.all(16),
        decoration:BoxDecoration(borderRadius:BorderRadius.circular(12), border:Border.all(color:C.border)),
        child:child)));
}

// ─── StatCard ────────────────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final IconData icon; final String value, label;
  final Color ic, ib; final String? sub;
  const StatTile({super.key,required this.icon,required this.value,required this.label,required this.ic,required this.ib,this.sub});
  @override Widget build(BuildContext ctx) => MCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:ib,borderRadius:BorderRadius.circular(8)),child:Icon(icon,color:ic,size:18)),
    const SizedBox(height:10),
    Text(value, style:const TextStyle(fontSize:20,fontWeight:FontWeight.w700,color:C.t1)),
    const SizedBox(height:2),
    Text(label, style:small),
    if(sub!=null) Text(sub!, style:TextStyle(fontSize:10,color:ic)),
  ]));
}

// ─── Empty ───────────────────────────────────────────────────────────────────
class Empty extends StatelessWidget {
  final IconData icon; final String msg; final String? sub, btnLabel; final VoidCallback? onBtn;
  const Empty({super.key,required this.icon,required this.msg,this.sub,this.btnLabel,this.onBtn});
  @override Widget build(BuildContext ctx) => Center(child:Padding(padding:const EdgeInsets.all(32),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      Icon(icon,size:56,color:C.t3), const SizedBox(height:14),
      Text(msg,style:h5.copyWith(color:C.t2),textAlign:TextAlign.center),
      if(sub!=null)...[const SizedBox(height:8),Text(sub!,style:body,textAlign:TextAlign.center)],
      if(btnLabel!=null)...[const SizedBox(height:16),Btn(label:btnLabel!,onTap:onBtn,width:180)],
    ])));
}

// ─── Badge ───────────────────────────────────────────────────────────────────
class Badge extends StatelessWidget {
  final String status;
  const Badge(this.status,{super.key});
  @override Widget build(BuildContext ctx) {
    Color bg,fg;
    switch(status.toLowerCase()){
      case 'upcoming': case 'active': bg=C.primaryLt; fg=C.primary; break;
      case 'completed': case 'paid': bg=C.greenLt; fg=C.green; break;
      case 'cancelled': case 'refunded': bg=C.redLt; fg=C.red; break;
      case 'pending': bg=C.amberLt; fg=C.amber; break;
      case 'suspended': bg=C.redLt; fg=C.red; break;
      default: bg=C.input; fg=C.t2;
    }
    return Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
      decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(99)),
      child:Text(status[0].toUpperCase()+status.substring(1), style:TextStyle(fontSize:11,color:fg,fontWeight:FontWeight.w600)));
  }
}

// ─── Avatar ──────────────────────────────────────────────────────────────────
class Av extends StatelessWidget {
  final String name; final double r; final Color? bg;
  const Av(this.name,{super.key,this.r=20,this.bg});
  @override Widget build(BuildContext ctx) {
    final parts=name.trim().split(' ');
    final ini=parts.length>=2?'${parts[0][0]}${parts[1][0]}'.toUpperCase():name.isNotEmpty?name[0].toUpperCase():'?';
    return CircleAvatar(radius:r,backgroundColor:bg??C.primaryLt,
      child:Text(ini,style:TextStyle(color:C.primary,fontSize:r*.58,fontWeight:FontWeight.w700)));
  }
}

// ─── StepBar ─────────────────────────────────────────────────────────────────
class StepBar extends StatelessWidget {
  final int cur, total;
  const StepBar({super.key,required this.cur,required this.total});
  @override Widget build(BuildContext ctx) => Row(
    children:List.generate(total,(i)=>Expanded(child:Container(
      margin:EdgeInsets.only(right:i<total-1?6:0), height:4,
      decoration:BoxDecoration(color:i<cur?C.primary:C.border,borderRadius:BorderRadius.circular(2))))));
}

// ─── SectionCard ─────────────────────────────────────────────────────────────
class SecCard extends StatelessWidget {
  final String? title; final Widget child; final String? action; final VoidCallback? onAction;
  const SecCard({super.key,this.title,required this.child,this.action,this.onAction});
  @override Widget build(BuildContext ctx) => MCard(pad:EdgeInsets.zero,child:Column(children:[
    if(title!=null) Padding(padding:const EdgeInsets.fromLTRB(16,14,8,0),
      child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
        Text(title!,style:h5),
        if(action!=null) TextButton(onPressed:onAction,child:Text(action!,style:const TextStyle(color:C.primary,fontSize:12))),
      ])),
    child,
  ]));
}

// ─── TabBar ──────────────────────────────────────────────────────────────────
class MTabBar extends StatelessWidget {
  final List<String> tabs; final List<int> counts; final int sel; final void Function(int) onSel;
  const MTabBar({super.key,required this.tabs,required this.counts,required this.sel,required this.onSel});
  @override Widget build(BuildContext ctx) => Container(color:C.card,padding:const EdgeInsets.fromLTRB(16,0,16,10),
    child:Row(children:List.generate(tabs.length,(i)=>GestureDetector(onTap:()=>onSel(i),
      child:Container(margin:const EdgeInsets.only(right:6,top:12),
        padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),
        decoration:BoxDecoration(color:i==sel?C.primary:Colors.transparent,borderRadius:BorderRadius.circular(99)),
        child:Text('${tabs[i]} (${i==sel?counts[i]:0})',
          style:TextStyle(fontSize:13,fontWeight:FontWeight.w500,color:i==sel?Colors.white:C.t2)))))));
}

// ─── InfoSection ─────────────────────────────────────────────────────────────
class InfoSec extends StatelessWidget {
  final IconData icon; final String title; final Widget child;
  const InfoSec({super.key,required this.icon,required this.title,required this.child});
  @override Widget build(BuildContext ctx) => MCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[
      Container(padding:const EdgeInsets.all(6),decoration:BoxDecoration(color:C.primaryLt,borderRadius:BorderRadius.circular(8)),child:Icon(icon,size:16,color:C.primary)),
      const SizedBox(width:8), Text(title,style:h5),
    ]),
    const SizedBox(height:16), child,
  ]));
}

// ─── Dropdown Field ───────────────────────────────────────────────────────────
class DropField extends StatelessWidget {
  final String label; final String? value; final List<String> items;
  final void Function(String?) onChange; final String? Function(String?)? validator;
  const DropField({super.key,required this.label,this.value,required this.items,required this.onChange,this.validator});
  @override Widget build(BuildContext ctx) => Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(label,style:label_style), const SizedBox(height:6),
    DropdownButtonFormField<String>(value:value,
      decoration:InputDecoration(filled:true,fillColor:C.input,contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:12),
        border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:const BorderSide(color:C.border)),
        enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:const BorderSide(color:C.border))),
      items:items.map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),
      onChanged:onChange, validator:validator),
  ]);
}

// ─── Card formatter ──────────────────────────────────────────────────────────
class CardFmt extends TextInputFormatter {
  @override TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final d=n.text.replaceAll(' ',''); if(d.length>16) return o;
    final buf=StringBuffer(); for(int i=0;i<d.length;i++){if(i>0&&i%4==0)buf.write(' ');buf.write(d[i]);}
    final t=buf.toString(); return TextEditingValue(text:t,selection:TextSelection.collapsed(offset:t.length));
  }
}
class ExpiryFmt extends TextInputFormatter {
  @override TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var t=n.text.replaceAll('/',''); if(t.length>4) t=t.substring(0,4);
    if(t.length>=2) t='${t.substring(0,2)}/${t.substring(2)}';
    return TextEditingValue(text:t,selection:TextSelection.collapsed(offset:t.length));
  }
}

// ─── Private alias ───────────────────────────────────────────────────────────
const label_style = label;
