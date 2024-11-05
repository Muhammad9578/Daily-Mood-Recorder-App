class Quote {
  int? id;
  String? author;
  String? quote;

  Quote({this.id, this.quote, this.author});

  factory Quote.fromJson(Map<dynamic, dynamic> json){
    return Quote(
        quote: json['quote'] ?? "",
        author: json['author'] ?? ""
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'quote': quote,
      'author': author
    };
  }

}
