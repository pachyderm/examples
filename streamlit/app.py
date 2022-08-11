import streamlit as st
import itertools
from pathlib import Path
import argparse

parser = argparse.ArgumentParser(description="Serve image from PFS")
parser.add_argument("--image-path", type=str, help="")

def paginator(label, items, items_per_page=10, on_sidebar=True):
    """Lets the user paginate a set of items.

    Parameters
    ----------
    label : str
        The label to display over the pagination widget.
    items : Iterator[Any]
        The items to display in the paginator.
    items_per_page: int
        The number of items to display per page.
    on_sidebar: bool
        Whether to display the paginator widget on the sidebar.
        
    Returns
    -------
    Iterator[Tuple[int, Any]]
        An iterator over *only the items on that page*, including
        the item's index.

    Example
    -------
    This shows how to display a few pages of fruit.
    >>> fruit_list = [
    ...     'Kiwifruit', 'Honeydew', 'Cherry', 'Honeyberry', 'Pear',
    ...     'Apple', 'Nectarine', 'Soursop', 'Pineapple', 'Satsuma',
    ...     'Fig', 'Huckleberry', 'Coconut', 'Plantain', 'Jujube',
    ...     'Guava', 'Clementine', 'Grape', 'Tayberry', 'Salak',
    ...     'Raspberry', 'Loquat', 'Nance', 'Peach', 'Akee'
    ... ]
    ...
    ... for i, fruit in paginator("Select a fruit page", fruit_list):
    ...     st.write('%s. **%s**' % (i, fruit))
    """

    # Figure out where to display the paginator
    if on_sidebar:
        location = st.sidebar.empty()
    else:
        location = st.empty()

    # Display a pagination selectbox in the specified location.
    items = list(items)
    n_pages = len(items)
    n_pages = (len(items) - 1) // items_per_page + 1
    page_format_func = lambda i: "Page %s" % i
    page_number = location.selectbox(label, range(n_pages), format_func=page_format_func)

    # Iterate over the items in the page to let the user display them.
    min_index = page_number * items_per_page
    max_index = min_index + items_per_page
    return itertools.islice(enumerate(items), min_index, max_index)

def demonstrate_image_pagination():
    args = parser.parse_args()
    images = (p.resolve() for p in Path(args.image_path).glob("**/*") if p.suffix in {".jpeg", ".jpg", ".png"})

    # images = Path(args.image_path).glob("*.jpeg") + Path(args.image_path).glob('*.png') + Path(args.image_path).glob('*.jpg')
    
    image_strings = [str(p) for p in images]
    print(image_strings)
    
    image_iterator = paginator("Select a sunset page", image_strings)
    indices_on_page, images_on_page = map(list, zip(*image_iterator))
    st.image(images_on_page, width=100, caption=indices_on_page)


if __name__ == '__main__':
    # hide_menu_style = """
    #     <style>
    #     #MainMenu {visibility: hidden;}
    #     </style>
    #     """
    # st.markdown(hide_menu_style, unsafe_allow_html=True)
    
    demonstrate_image_pagination()