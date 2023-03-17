import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kisiler_uygulamasi_firebase/KisiDetaySayfa.dart';
import 'package:kisiler_uygulamasi_firebase/KisiKayitSayfa.dart';
import 'package:kisiler_uygulamasi_firebase/Kisiler.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Anasayfa(),
    );
  }
}

class Anasayfa extends StatefulWidget {

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {

  bool aramaYapiliyorMu = false;
  String aramaKelimesi = "";

  var refKisiler = FirebaseDatabase.instance.ref().child("kisiler");

  Future<void> sil(String kisi_id) async{
    refKisiler.child(kisi_id).remove();
   /* setState(() { StreamBuilder kullanıyoruz setState metoduna bu yüzden gerek yok
    }); */
  }

  Future<bool> uygulamayiKapat() async{
    await exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            uygulamayiKapat();
          },
        ),
        title: aramaYapiliyorMu ?
        TextField(
          decoration: InputDecoration(hintText: "Arama için bir şey yazın"),
          onChanged: (aramaSonucu){
            print("Arama sonucu : $aramaSonucu");
            setState(() {
              aramaKelimesi = aramaSonucu;
            });
          },
        )
            : Text("Kişiler Uygulaması"),
        actions: [
          aramaYapiliyorMu ?
          IconButton(
              onPressed: (){
                setState(() {
                  aramaYapiliyorMu = false;
                  aramaKelimesi = "";
                });
              },
              icon: Icon(Icons.cancel_outlined, color: Colors.deepOrangeAccent,)
          )
              :IconButton(
            onPressed: (){
              setState(() {
                aramaYapiliyorMu = true;
              });
            },
            icon: Icon(Icons.search, color: Colors.black,),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: uygulamayiKapat,
        child: StreamBuilder<DatabaseEvent>(
          stream: refKisiler.onValue,
          builder: (context, event){
            if(event.hasData){
              List<Kisiler> kisilerListesi = [];

              var gelenDegerler = event.data!.snapshot.value as dynamic;

              if(gelenDegerler != null){
                gelenDegerler.forEach((key, nesne){
                  var gelenKisi = Kisiler.fromJson(key, nesne);

                  if(aramaYapiliyorMu){
                    if(gelenKisi.kisi_ad.contains(aramaKelimesi)){
                      kisilerListesi.add(gelenKisi);
                    }
                  } else  {
                    kisilerListesi.add(gelenKisi);
                  }
                });
              }
              return ListView.builder(
                itemCount: kisilerListesi!.length,
                itemBuilder: (context, index){  // döngü gibi olan
                  var kisi = kisilerListesi[index];
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => KisiDetaySayfa(kisi: kisi,)));
                    },
                    child: Card(
                      child: SizedBox( height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(kisi.kisi_ad, style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(kisi.kisi_tel,),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey,),
                              onPressed: (){
                                sil(kisi.kisi_id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else  {
              return Center();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => KisiKayitSayfa()));
        },
        tooltip: "Kişi Ekle",
        child: const Icon(Icons.add),
      ),
    );
  }
}
