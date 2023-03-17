class Kisiler{
  String kisi_id;
  String kisi_ad;
  String kisi_tel;

  Kisiler(this.kisi_id, this.kisi_ad, this.kisi_tel);

  factory Kisiler.fromJson(String key, Map<dynamic,dynamic> json){
    return Kisiler(key, json["kisi_ad"] as String, json["kisi_tel"] as String); // key 1 ise 1 in kisi_ad ve kisi_tel bilgilerini alacak
  }
}