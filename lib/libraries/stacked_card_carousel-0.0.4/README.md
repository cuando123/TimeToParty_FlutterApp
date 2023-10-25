# stacked_card_carousel

A widget for creating a vertical carousel with stacked cards.

<p align="center">
<img src="https://raw.githubusercontent.com/grihlo/stacked_card_carousel/master/example/assets/gifs/stacked_cards.gif" alt="cardsStack" title="StackedCardCarouselType.cardsStack" height="500"/>
<img src="https://raw.githubusercontent.com/grihlo/stacked_card_carousel/master/example/assets/gifs/fade_out_cards.gif" alt="fadeOutStack" title="StackedCardCarouselType.fadeOutStack" height="500"/>
</p>

## 📱 Usage

1. Import package in your file

  ```
  import 'package:stacked_card_carousel/stacked_card_carousel.dart';
  ```

2. Use `StackedCardCarousel` widget

  ```
    StackedCardCarousel(
        items: cards,
    );
  ```

## 🎛 Attributes
| Attribute | Data type | Description | Default |
|--|--|--|--|
| items | List<Widget> | List of card widgets. | - |
| type | StackedCardCarouselType | A type of cards stack carousel. | cardsStack |
| initialOffset | double | Initial vertical top offset for cards. | 40.0 |
| spaceBetweenItems | double | Vertical space between items. Value start from top of a first item. | 400.0 |
| applyTextScaleFactor | bool | If set to true scales up space and position linearly according to text scale factor. Scaling down is not included. | true |
| pageController | PageController | Use it for your custom page controller. | PageController() |
| onPageChanged | void Function(int pageIndex) | Listen to page index changes. | null |

## 💻 Author
Grigori Hlopkov - [GitHub](https://github.com/grihlo)
