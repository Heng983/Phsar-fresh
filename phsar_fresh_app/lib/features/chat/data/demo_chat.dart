import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/data/product_details.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/chat/domain/model/chat_message.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

/// Scripted conversations for the offline demo; no AI or network is involved.
ChatMessage demoChatReply(List<ChatMessage> history, AppLocalizations l10n) {
  final text = history
      .lastWhere((message) => message.isUser)
      .text
      .toLowerCase();
  bool matches(String pattern) =>
      RegExp(pattern, caseSensitive: false).hasMatch(text);
  final isRecipe = matches(r'recipe|how.*(?:cook|make)|របៀប|ចម្អិន');
  final isIngredients = matches(r'ingredient|គ្រឿងផ្សំ');
  final mentionsLokLak = RegExp(
    r'lok\s*lak|loc\s*lac|ឡុកឡាក់',
    caseSensitive: false,
  );
  final lokLak =
      mentionsLokLak.hasMatch(text) ||
      ((isRecipe || isIngredients) &&
          history.any(
            (message) =>
                message.isUser && mentionsLokLak.hasMatch(message.text),
          ));
  String reply;
  List<MarketProduct> products = const [];
  if (matches(r'\b(?:thank|thanks)\b|អរគុណ')) {
    reply = l10n.chatDemoThanks;
  } else if (matches(r'deliver|shipping|ដឹកជញ្ជូន')) {
    reply = l10n.chatDeliveryReply;
  } else if (matches(r'\border|បញ្ជាទិញ')) {
    reply = l10n.chatOrdersReply;
  } else if (isRecipe) {
    reply = lokLak ? l10n.chatDemoLokLakRecipe : l10n.chatDemoRecipeReply;
  } else if (lokLak) {
    reply = l10n.chatDemoLokLakReply;
  } else if (isIngredients) {
    reply = l10n.chatDemoIngredientsReply;
    products = _mealProducts;
  } else if (matches(r'fresh|fruit|vegetable|produce|ស្រស់|ផ្លែឈើ|បន្លែ')) {
    reply = l10n.chatDemoFreshReply;
    products = [greensProduct, fruitsProduct, eggsProduct, citrusDealProduct];
  } else if (matches(
    r'meal|cook|dinner|lunch|breakfast|food|rice|ម្ហូប|បាយ|ញ៉ាំ',
  )) {
    reply = l10n.chatDemoMealReply;
    products = _mealProducts;
  } else if (matches(r'\b(?:hello|hi|hey)\b|សួស្តី|ជំរាបសួរ')) {
    reply = l10n.chatDemoGreeting;
  } else {
    reply = l10n.chatFallbackReply;
  }
  return ChatMessage(
    isUser: false,
    text: reply,
    sentAt: DateTime.now(),
    products: [
      for (final item in products)
        ChatProduct(
          id: item.id,
          name: item.name,
          nameKm: item.nameKm,
          origin: productDetailFor(item).farmAddress,
          category: item.category.name,
          unit: item.unitLabel(l10n),
          priceCents: item.priceInCents,
          imageUrl: item.imageUrl,
          inStock: item.inStock,
        ),
    ],
  );
}

final _mealProducts = [riceProduct, greensProduct, eggsProduct];
