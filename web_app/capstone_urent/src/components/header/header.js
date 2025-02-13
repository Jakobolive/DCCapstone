//imports
import Link from 'next/link';   //Import Link for client-side routing

const Header = () => {
    return (
      <header>
        <nav className="navbar">
          <ul className="nav-links">
            <li><Link href="/">Home</Link></li>      
            <li><Link href="/about">About</Link></li> 
            <li><Link href="/login">Login</Link></li>
            <li><Link href="/contact">Contact</Link></li> 
          </ul>
        </nav>
      </header>
    );
  };
  
  export default Header;