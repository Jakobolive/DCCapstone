// imports
import Header from './header';  // Import Header component
import Footer from './footer';  // Import Footer component

const Layout = ({ children }) => {
    return (
    <div>
      <Header />  {/* Header will be on every page */}
      <main>{children}</main>  {/* This will render the page content */}
      <Footer />  {/* Footer will be on every page */}
    </div>
    )
}

export default Layout;