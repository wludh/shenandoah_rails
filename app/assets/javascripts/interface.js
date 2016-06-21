function reveal_browse(){
    $("#browse-div").addClass('visible');
    $("#search-div").removeClass('visible');
    $("#visualize-div").removeClass('visible');
};

function reveal_search(){
    $("#browse-div").removeClass('visible');
    $("#search-div").addClass('visible');
    $("#visualize-div").removeClass('visible');
};

function reveal_visualize(){
    $("#browse-div").removeClass('visible');
    $("#search-div").removeClass('visible');
    $("#visualize-div").addClass('visible');
};

function generate_css_link(){
    var cssLink = document.createElement("link"); 
    // cssLink.href = "css/custom.css";
    cssLink.href = "https://fonts.googleapis.com/css?family=Roboto:400,500";
    cssLink.rel = "stylesheet"; 
    cssLink.type = "text/css";
    return cssLink;
};

function add_css_to_iframe(){
    frames['search-frame'].document.head.appendChild(generate_css_link());
};

function prep_page(){
    add_css_to_iframe();    
    reveal_search();
};