import 'package:flutter/material.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';
import 'package:merrymakin/commons/widgets/pro_tab_view.dart';

// This file contains a comprehensive emoji keyboard with search functionality
// For brevity, I'll include the core structure with a representative set of emojis
// The full exhaustive list can be expanded as needed

class ProEmojiKeyboard extends StatefulWidget {
  final Function(String emoji) onEmojiSelected;
  final List<String>? currentUserReaction;

  const ProEmojiKeyboard({
    super.key,
    required this.onEmojiSelected,
    this.currentUserReaction,
  });

  @override
  State<ProEmojiKeyboard> createState() => _ProEmojiKeyboardState();
}

class _ProEmojiKeyboardState extends State<ProEmojiKeyboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Comprehensive emoji categories - representative comprehensive list
  final Map<String, List<String>> _emojiCategories = {
    '🔥': [
      // top 15 emojis which are popular happy occasions and celebrations
      '😃', 
      '🤩', '😘', '😝', '🥵', '👅', '🥶', '😵', '🤯', '🤠', '🥳', '😎', '🤓', '🧐',
      '🤮','😕', '😟', '🙁', '😳', '🥺', '😦', '😥',
      '😭', '😱', '😖','🤬', '👿', '🎉', '🎊', '🎈', '🎁', '💩', 
      '👍', '👎', '👏', '🙌', '🙏',
      '🤌', '🤏', '✌️', '🤘', '🤙', 
      '🖕', '✊', '👊','🤝',
    ],
    '🙂': [
      '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃', '😉', '😊', '😇', '🥰', '😍',
      '🤩', '😘', '😗', '😚', '😙', '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔',
      '🤐', '🤨', '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '🤥', '😌', '😔', '😪', '🤤', '😴',
      '😷', '🤒', '🤕', '🤢', '🤮', '🤧', '🥵', '🥶', '😵', '🤯', '🤠', '🥳', '😎', '🤓', '🧐',
      '😕', '😟', '🙁', '☹️', '😮', '😯', '😲', '😳', '🥺', '😦', '😧', '😨', '😰', '😥', '😢',
      '😭', '😱', '😖', '😣', '😞', '😓', '😩', '😫', '🥱', '😤', '😡', '😠', '🤬', '😈', '👿',
      '💀', '☠️', '💩', '🤡', '👹', '👺', '👻', '👽', '👾', '🤖', '👍', '👎', '👏', '🙌', '🙏',
      '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏', '✌️', '🤞', '🤟', '🤘', '🤙', '👈', '👉',
      '👆', '🖕', '👇', '☝️', '✊', '👊', '🤛', '🤜', '👐', '🤲', '🤝', '✍️', '💪', '🦾', '🦿',
    ],
    '🐶': [
      '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐽', '🐸',
      '🐵', '🙈', '🙉', '🙊', '🐒', '🐔', '🐧', '🐦', '🐤', '🐣', '🐥', '🦆', '🦅', '🦉', '🦇',
      '🐺', '🐗', '🐴', '🦄', '🐝', '🐛', '🦋', '🐌', '🐞', '🐜', '🦟', '🦗', '🕷️', '🕸️', '🦂',
      '🐢', '🐍', '🦎', '🦖', '🦕', '🐙', '🦑', '🦐', '🦞', '🦀', '🐡', '🐠', '🐟', '🐬', '🐳',
      '🐋', '🦈', '🐊', '🐅', '🐆', '🦓', '🦍', '🦧', '🐘', '🦛', '🦏', '🐪', '🐫', '🦒', '🦘',
      '🌲', '🌳', '🌴', '🌵', '🌾', '🌿', '☘️', '🍀', '🍁', '🍂', '🍃', '🍄',
    ],
    '🍉': [
      '🍇', '🍈', '🍉', '🍊', '🍋', '🍌', '🍍', '🥭', '🍎', '🍏', '🍐', '🍑', '🍒', '🍓', '🥝',
      '🍅', '🥥', '🥑', '🍆', '🥔', '🥕', '🌽', '🌶️', '🥒', '🥬', '🥦', '🧄', '🧅', '🥜', '🌰',
      '🍞', '🥐', '🥖', '🫓', '🥨', '🥯', '🥞', '🧇', '🧈', '🍳', '🥚', '🧀', '🥓', '🥩', '🍗',
      '🍖', '🦴', '🌭', '🍔', '🍟', '🍕', '🥪', '🥙', '🧆', '🌮', '🌯', '🫔', '🥗', '🥘', '🫕',
      '🥫', '🍝', '🍜', '🍲', '🍛', '🍣', '🍱', '🥟', '🦪', '🍤', '🍙', '🍚', '🍘', '🍥', '🥠',
      '🥮', '🍢', '🍡', '🍧', '🍨', '🍦', '🥧', '🧁', '🍰', '🎂', '🍮', '🍭', '🍬', '🍫', '🍿',
      '🍩', '🍪', '🍯', '🥛', '🍼', '🫖', '☕️', '🍵', '🧃', '🥤', '🧋', '🍶', '🍺', '🍻', '🥂',
      '🍷', '🥃', '🍸', '🍹', '🧉', '🍾', '🧊',
    ],
    '⚽': [
      '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉', '🎱', '🏓', '🏸', '🏒', '🏑', '🏏', '🥍',
      '🏹', '🎣', '🤿', '🥊', '🥋', '🎽', '🛹', '🛷', '⛸️', '🥌', '🎿', '⛷️', '🏂', '🪂', '🏋️',
      '🤼', '🤸', '⛹️', '🤺', '🤾', '🏌️', '🏇', '🧘', '🏄', '🏊', '🤽', '🚣', '🧗', '🚵', '🚴',
      '🏆', '🥇', '🥈', '🥉', '🏅', '🎖️', '🏵️', '🎗️', '🎫', '🎟️', '🎪', '🤹', '🎭', '🩰', '🎨',
      '🎬', '🎤', '🎧', '🎼', '🎹', '🥁', '🪘', '🎷', '🎺', '🪗', '🎸', '🪕', '🎻', '🎲', '♟️',
      '🎯', '🎳', '🎮', '🎰', '🧩',
    ],
    '🚗': [
      '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐', '🛻', '🚚', '🚛', '🚜', '🏍️',
      '🛵', '🦽', '🦼', '🛴', '🚲', '🛹', '🛼', '🚁', '🛸', '✈️', '🛫', '🛬', '🛩️', '💺', '🚀',
      '🛰️', '🚂', '🚃', '🚄', '🚅', '🚆', '🚇', '🚈', '🚉', '🚊', '🚝', '🚞', '🚋', '🚢', '⛵',
      '🛶', '🚤', '🛥️', '🛳️', '⛴️', '⚓', '⛽', '🚨', '🚥', '🚦', '🚧', '🛑', '🚏', '🗺️', '🧭',
      '⛱️', '🏖️', '🏝️', '🏜️', '🌋', '⛰️', '🏔️', '🗻', '🏕️', '⛺', '🏠', '🏡', '🏘️', '🏚️', '🏗️',
      '🏭', '🏢', '🏬', '🏣', '🏤', '🏥', '🏦', '🏨', '🏪', '🏫', '🏩', '💒', '🏛️', '⛪', '🕌',
      '🛕', '🕍', '⛩️', '🕋', '⛲', '🌁', '🌃', '🏙️', '🌄', '🌅', '🌆', '🌇', '🌉', '♨️', '🎠',
      '🎡', '🎢', '💈',
    ],
    '💎': [
      '⌚', '📱', '📲', '💻', '⌨️', '🖥️', '🖨️', '🖱️', '🖲️', '🕹️', '🗜️', '💾', '💿', '📀', '📼',
      '📷', '📸', '📹', '🎥', '📽️', '🎞️', '📞', '☎️', '📟', '📠', '📺', '📻', '🎙️', '🎚️', '🎛️',
      '⏱️', '⏲️', '⏰', '🕰️', '⌛', '⏳', '📡', '🔋', '🔌', '💡', '🔦', '🕯️', '🧯', '🛢️', '💸',
      '💵', '💴', '💶', '💷', '💰', '💳', '💎', '⚖️', '🪜', '🧰', '🪛', '🔧', '🔨', '⚒️', '🛠️',
      '⛏️', '🪚', '🔩', '⚙️', '🪤', '🧱', '⛓️', '🧲', '🔫', '💣', '🧨', '🪓', '🔪', '🗡️', '⚔️',
      '🛡️', '🚬', '⚰️', '🪦', '⚱️', '🏺', '🔮', '📿', '🧿', '💈', '⚗️', '🔭', '🔬', '🕳️', '🩹',
      '🩺', '💊', '💉', '🩸', '🧬', '🦠', '🧫', '🧪', '🌡️', '🧹', '🪠', '🧺', '🧻', '🚽', '🚰',
      '🚿', '🛁', '🛀', '🧼', '🪥', '🪒', '🧽', '🪣', '🧴', '🛎️', '🔑', '🗝️', '🚪', '🪑', '🛋️',
      '🛏️', '🛌', '🧸', '🪆', '🪅', '🖼️', '🪞', '🪟', '🛍️', '🛒', '🎁', '🎈', '🎏', '🎀', '🪄',
      '🎊', '🎉', '🎎', '🏮', '🎐', '🧧', '✉️', '📩', '📨', '📧', '💌', '📥', '📤', '📦', '🏷️',
      '🪧', '📪', '📫', '📬', '📭', '📮', '📯', '📜', '📃', '📄', '📑', '🧾', '📊', '📈', '📉',
      '🗒️', '🗓️', '📆', '📅', '🗑️', '📇', '🗃️', '🗳️', '🗄️', '📋', '📁', '📂', '🗂️', '📓', '📔',
      '📒', '📕', '📗', '📘', '📙', '📚', '📖', '🔖', '🧷', '🔗', '📎', '🖇️', '📐', '📏', '🧮',
      '📌', '📍', '✂️', '🖊️', '🖋️', '✒️', '🖌️', '🖍️', '📝', '✏️', '🔍', '🔎', '🔏', '🔐', '🔒',
      '🔓',
    ],
    '❤️': [
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔', '❣️', '💕', '💞', '💓', '💗',
      '💖', '💘', '💝', '💟', '☮️', '✝️', '☪️', '🕉️', '☸️', '✡️', '🔯', '🕎', '☯️', '☦️', '🛐',
      '⛎', '♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓', '🆔', '⚛️', '🉑',
      '☢️', '☣️', '📴', '📳', '🈶', '🈚', '🈸', '🈺', '🈷️', '✴️', '🆚', '💮', '🉐', '㊙️', '㊗️',
      '🈴', '🈵', '🈹', '🈲', '🅰️', '🅱️', '🆎', '🆑', '🅾️', '🆘', '❌', '⭕', '🛑', '⛔', '📛',
      '🚫', '💯', '💢', '♨️', '🚷', '🚯', '🚳', '🚱', '🔞', '📵', '🚭', '❗', '❓', '❕', '❔',
      '‼️', '⁉️', '🔅', '🔆', '〽️', '⚠️', '🚸', '🔱', '⚜️', '🔰', '♻️', '✅', '🈯', '💹', '❇️',
      '✳️', '❎', '🌐', '💠', 'Ⓜ️', '🌀', '💤', '🏧', '🚾', '♿', '🅿️', '🈳', '🈂️', '🛂', '🛃',
      '🛄', '🛅', '🚹', '🚺', '🚼', '🚻', '🚮', '🎦', '📶', '🈁', '🔣', 'ℹ️', '🔤', '🔡', '🔠',
      '🔢', '#️⃣', '*️⃣', '0️⃣', '1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '6️⃣', '7️⃣', '8️⃣', '9️⃣', '🔟',
      '🔺', '🔻', '💠', '🔸', '🔹', '🔶', '🔷', '🔳', '🔲', '▪️', '▫️', '◾', '◽', '◼️', '◻️',
      '🟥', '🟧', '🟨', '🟩', '🟦', '🟪', '⬛', '⬜', '🟫', '🔈', '🔇', '🔉', '🔊', '🔔', '🔕',
      '📣', '📢', '💬', '💭', '🗯️', '♠️', '♣️', '♥️', '♦️', '🃏', '🎴', '🀄', '🕐', '🕑', '🕒',
      '🕓', '🕔', '🕕', '🕖', '🕗', '🕘', '🕙', '🕚', '🕛',
    ],
    '🏁': [
      '🏳️', '🏴', '🏁', '🚩', '🏳️‍🌈', '🏳️‍⚧️', '🇺🇸', '🇬🇧', '🇨🇦', '🇦🇺', '🇩🇪', '🇫🇷', '🇮🇹',
      '🇪🇸', '🇯🇵', '🇨🇳', '🇮🇳', '🇧🇷', '🇷🇺', '🇰🇷', '🇲🇽', '🇮🇩', '🇳🇱', '🇹🇷', '🇸🇦', '🇨🇭',
      '🇦🇷', '🇵🇱', '🇸🇪', '🇧🇪', '🇹🇭', '🇪🇬', '🇬🇷', '🇵🇹', '🇩🇰', '🇫🇮', '🇨🇿', '🇮🇪', '🇷🇴',
      '🇭🇺', '🇻🇳', '🇳🇿', '🇵🇰', '🇦🇹', '🇨🇴', '🇬🇷', '🇺🇦', '🇲🇾', '🇨🇱', '🇸🇬', '🇳🇴', '🇵🇪',
      '🇭🇰', '🇧🇩', '🇵🇭', '🇿🇦', '🇲🇦', '🇩🇿', '🇳🇬', '🇮🇷', '🇪🇹', '🇰🇪', '🇹🇿', '🇲🇲', '🇺🇿',
    ],
  };

  // Comprehensive emoji keywords for search
  // In a production app, this would be more extensive
  final Map<String, List<String>> _emojiKeywords = {
    '😀': ['grinning', 'face', 'happy', 'smile', 'joy'],
    '🐶': ['dog', 'puppy', 'pet', 'canine'],
    '🐱': ['cat', 'kitten', 'pet', 'feline'],
    '🍕': ['pizza', 'slice', 'food'],
    '❤️': ['love', 'like', 'heart', 'red heart', 'red',   ],
    '💔': ['broken', 'heart', 'sad', 'broken heart', 'broken heart'],
    '💕': ['love', 'like', 'heart', 'red heart', 'red heart'],
    '💞': ['love', 'like', 'heart', 'red heart', 'red heart'],
    '💓': ['love', 'like', 'heart', 'red heart', 'red heart'],
    '💗': ['love', 'like', 'heart', 'red heart', 'red heart'],
    '💖': ['love', 'like', 'heart', 'red heart', 'red heart'],
    '💘': ['love', 'like', 'heart', 'red heart', 'red heart'],
    '💝': ['love', 'like', 'heart', 'red heart', 'red heart'],
    '💟': ['love', 'like', 'heart', 'red heart', 'red heart'],
    '☮️': ['peace', 'peace sign', 'peace symbol'],
    '✝️': ['cross', 'christian', 'christianity'],
    '☪️': ['muslim', 'muslim', 'islam'],
    '🕉️': ['hindu', 'hinduism'],
    '☸️': ['buddhist', 'buddhistism'],
    '✡️': ['jewish', 'jewish'],
    '🔯': ['jewish star', 'jewish star'],
    '🕎': ['hanukkah', 'hanukkah'],
    '☯️': ['tao', 'taoism'],
    '☦️': ['sikh', 'sikhism'],
    '🛐': ['pray', 'pray', 'pray'],
    '⛎': ['scorpio', 'scorpio'],
    '♈': ['aries', 'aries'],
    '👍': ['thumbs', 'up', 'like', 'good', 'yes'],
    '🔥': ['fire', 'flame', 'hot', 'lit'],
    '💯': ['hundred', 'points', 'perfect', '100'],
    '✨': ['sparkles', 'star', 'magic'],
    '🇺🇸': ['united', 'states', 'usa', 'america', 'american', 'us'],
    '🇬🇧': ['united', 'kingdom', 'uk', 'britain', 'british'],
    '🇯🇵': ['japan', 'japanese'],
    '🇮🇳': ['india', 'indian'],
    '🇨🇳': ['china', 'chinese'],
    '🇫🇷': ['france', 'french'],
    '🇩🇪': ['germany', 'german'],
    '🇮🇩': ['indonesia', 'indonesian'],
    '🇱🇦': ['laos', 'lao'],
    '🇲🇾': ['malaysia', 'malaysian'],
    '🇲🇽': ['mexico', 'mexican'],
    '🇳🇱': ['netherlands', 'dutch'],
    '🇳🇴': ['norway', 'norwegian'],
    '🇵🇭': ['philippines', 'filipino'],
    '🇷🇴': ['romania', 'romanian'],
    '🇸🇦': ['saudi', 'saudi arabia'],
    '🇸🇬': ['singapore', 'singaporean'],
    '🇸🇪': ['sweden', 'swedish'],
    '😘': ['kiss', 'kissing', 'kisses', 'kissing', 'kissing'],
    '😍': ['love', 'like', 'heart', 'red heart', 'red heart'],
    '😊': ['smile', 'happy', 'joy', 'joyful', 'joyful'],
    '😋': ['eat', 'eating', 'food', 'foodie', 'foodie'],
    '😎': ['cool', 'cool', 'cool', 'cool', 'cool'],
    '😭': ['cry', 'crying', 'sad', 'sad', 'sad'],
    '😡': ['angry', 'angry', 'angry', 'angry', 'angry'],
    '😠': ['angry', 'angry', 'angry', 'angry', 'angry'],
    '😈': ['devil', 'devil', 'devil', 'devil', 'devil'],
    '😐': ['neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
    '😑': ['neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
    '😶': ['neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
    '😏': ['smirk', 'smirk', 'smirk', 'smirk', 'smirk'],
    '😒': ['disappointed', 'disappointed', 'disappointed', 'disappointed', 'disappointed'],
    '😞': ['disappointed', 'disappointed', 'disappointed', 'disappointed', 'disappointed'],
    '😔': ['sad', 'sad', 'sad', 'sad', 'sad'],
    '😟': ['anxious', 'anxious', 'anxious', 'anxious', 'anxious'],
    '😕': ['confused', 'confused', 'confused', 'confused', 'confused'],
    '🙁': ['sad', 'sad', 'sad', 'sad', 'sad'],
    '🙂': ['smile', 'happy', 'joy', 'joyful', 'joyful'],
    '🙃': ['smile', 'happy', 'joy', 'joyful', 'joyful'],
    '🤔': ['think', 'thinking', 'think', 'thinking', 'thinking'],
    '🤨': ['doubt', 'doubtful', 'doubt', 'doubtful', 'doubtful'],
    '🤯': ['shock', 'shocked', 'shock', 'shocked', 'shocked'],
    '🤠': ['cowboy', 'cowboy', 'cowboy', 'cowboy', 'cowboy'],
    '🤡': ['clown', 'clown', 'clown', 'clown', 'clown'],
    '🎈': ['balloon', 'balloon', 'balloon', 'balloon', 'balloon'],
    '🎉': ['celebrate', 'celebration', 'celebrate', 'celebration', 'celebration'],
    '🎊': ['celebrate', 'celebration', 'celebrate', 'celebration', 'celebration'],
    '🎁': ['gift', 'gift', 'gift', 'gift', 'gift'],
    '🎄': ['christmas', 'christmas tree', 'christmas tree', 'christmas tree', 'christmas tree'],
    '🎆': ['fireworks', 'fireworks', 'fireworks', 'fireworks', 'fireworks'],
    '🎇': ['fireworks', 'fireworks', 'fireworks', 'fireworks', 'fireworks'],
    '💩': ['poop', 'poop', 'poop', 'poop', 'poop'],
    '👅': ['tongue', 'tongue', 'tongue', 'tongue', 'tongue'],
    '👀': ['eyes', 'eye', 'eyes', 'eye', 'eye'],
    '👁️': ['eyes', 'eye', 'eyes', 'eye', 'eye'],
    '👁️‍🗨️': ['eyes', 'eye', 'eyes', 'eye', 'eye'],
        // Add more keywords as needed - this is a representative sample
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(String emoji, String query) {
    if (query.isEmpty) return true;
    final queryLower = query.toLowerCase().trim();
    final queryWords = queryLower.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (queryWords.isEmpty) return true;
    
    final keywords = _emojiKeywords[emoji] ?? [];
    for (final queryWord in queryWords) {
      final matchesKeyword = keywords.any((keyword) {
        final keywordLower = keyword.toLowerCase();
        return keywordLower.contains(queryWord) || 
               queryWord.contains(keywordLower) ||
               keywordLower == queryWord;
      });
      final matchesEmoji = emoji.contains(queryLower);
      if (matchesKeyword || matchesEmoji) return true;
    }
    return false;
  }

  List<String> _getFilteredEmojis(String category) {
    final categoryEmojis = _emojiCategories[category] ?? [];
    if (_searchQuery.isEmpty) return categoryEmojis;
    return categoryEmojis.where((emoji) => _matchesSearch(emoji, _searchQuery)).toList();
  }

  List<String> _getAllFilteredEmojis() {
    if (_searchQuery.isEmpty) return [];
    final allEmojis = <String>[];
    for (var category in _emojiCategories.keys) {
      allEmojis.addAll(_getFilteredEmojis(category));
    }
    return allEmojis;
  }

  Widget _buildEmojiGrid(List<String> emojis) {
    if (emojis.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(generalAppLevelPadding * 2),
          child: ProText(
            _searchQuery.isNotEmpty
                ? 'No emojis found for "$_searchQuery"'
                : 'No emojis in this category',
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        final isSelected = widget.currentUserReaction?.contains(emoji) ?? false;
        return GestureDetector(
          onTap: () => widget.onEmojiSelected(emoji),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: 28,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _emojiCategories.keys.toList();
    
    if (_searchQuery.isNotEmpty) {
      final allFilteredEmojis = _getAllFilteredEmojis();
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(generalAppLevelPadding),
            child: ProTextField(
              label: 'Search',
              hintText: 'Search emojis...',
              textEditingController: _searchController,
              prefixWidget: const Icon(Icons.search),
              suffixWidget: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              ),
            ),
          ),
          allFilteredEmojis.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(generalAppLevelPadding * 2),
                    child: ProText(
                      'No emojis found for "$_searchQuery"',
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
                    child: _buildEmojiGrid(allFilteredEmojis),
                  ),
                ),
        ],
      );
    }

    final categoryTabs = categories.map((cat) => cat).toList();
    final categoryWidgets = categories.map((category) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
          child: _buildEmojiGrid(_getFilteredEmojis(category)),
        ),
      );
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(generalAppLevelPadding),
          child: ProTextField(
            label: 'Search',
            hintText: 'Search emojis...',
            textEditingController: _searchController,
            prefixWidget: const Icon(Icons.search),
          ),
        ),
        ProTabView(
          height: null,
          isTabsAtBottom: true,
          childrenTabTitle: categoryTabs,
          children: categoryWidgets,
        ),
      ],
    );
  }
}

