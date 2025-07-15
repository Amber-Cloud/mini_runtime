import { NavLink } from "react-router-dom";
import logo from "/images/logo.png";

const Navbar: React.FC = () => {
  const linkClass = ({ isActive }: { isActive: boolean }) =>
    isActive ? "c-nav__link c-nav__link--active" : "c-nav__link";

  return (
    <nav className="c-nav">
      <div className="c-nav__content">
        <NavLink className="c-nav__brand" to="/">
          <img className="c-nav__logo" src={logo} alt="Cat Shelter Logo" />
          <span className="c-nav__title">Alisa's Cat Shelter</span>
        </NavLink>
        <div className="c-nav__menu">
          <NavLink to="/" className={linkClass}>
            Home
          </NavLink>
          <NavLink to="/about" className={linkClass}>
            About Us
          </NavLink>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
